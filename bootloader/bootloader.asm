;cpu will start in real mode
org 0x7C00	;BIOS will put the bootloader at 0x7C00
bits 16		;output 16bit code for real mode

;---set up memory segments---
;in real mode an absolute address is calculated by segmentRegister * 16 + offset
;while the offset is usually encoded in an instruction that has memory operands
;therefore the segment registers must be = 0x7C00 / 16 = 0x7C0
mov ax, 0		;we set them to 0 because "org" (line 2) will do the trick
;mov ax, 0x7C0	;somehow this didnt work
mov ds, ax		;data segement

;we want to load our kernel to 0x1000
mov ax, 0x100	;dont forget that this is 0x1000 / 16 = 0x100
mov es, ax		;extra data segment

;---load the kernel---
;we need to do this in real mode because only there the bios services are available
;print welcome message
mov si, g_loadMsg
call BIOS_PrintString

;reset floppy drive
mov ah, 0	;function code, 0 = reset
mov dl, 0	;drive = 0
int 0x13
jc _fail

;load first sector (real first (number 0) is this bootloader)
mov si, 2	;sector = 1
call BIOS_DriveReadSector

;---call kernel---
cli		;disable interrupts

lgdt [gdtDescriptor]

;switch to protected mode
mov eax, cr0
or eax, 1
mov cr0, eax




jmp 0x8:bootload32	;far jump to 32 bit code in bootloader
					;the 8 is the offset to the entry to the code section table in GDT



; FUNCTIONS
; only available in real mode!!!

;params:
;si = zero terminated ascii string
BIOS_PrintString:
	mov ah, 0xE		;bios service code (print char on screen)
	
	_printStrLoop:
	mov al, [si]	;get next char
	
	;check if char == 0
	cmp al, 0
	jz	_endPrintStr
	
	int 0x10		;video interrupt
	
	inc si			;increment s
	jmp _printStrLoop
	
	_endPrintStr:
	ret
	
	
;params:
;si = sector number
;this function will store result in es:bx
BIOS_DriveReadSector:
	mov ah, 2	;function code, 2 = read sector
	mov dl, 0	;drive = 0
	mov dh, 0	;head = 0
	mov cx, si	;copy sector number (si must be < 256)
	mov ch, 0	;cylinder = 0
	
	mov al, 1	;number of sectors to read
	
	mov	bx, si	;bx is the offset, we use the sectorNumber * sectorSize to determine it
	shl bx, 9	;multiply by sector size (which is 512)
	
	int 0x13	;initiate the operation
	jc _fail	;carry flag is set if a read error occured
	
	ret
	
_fail:
	mov si, g_errMsg
	call BIOS_PrintString
	hlt	;stop processor
	
	
	
;from here were in protected mode
bits 32
bootload32:
	mov ax, 0x10	;index to data section
	mov ds, ax		;set the data section
	
	;mov ss, ax
	;mov esp, 0x90000
	
	mov DWORD [0xb8000], 0x7690748	;Print "Hi" at the top left of the screen
	mov DWORD [0xb8004], 0x7690748 ;do it again
	
	jmp $


;DATA
g_loadMsg: db "Welcome to ACOS bootloader.", 10, 13, 10, "Loading Kernel...", 0
g_errMsg: db "An error occured while trying to load the kernel. Restart computer to continue...", 0

;Global Descriptor Table
;accessFlags = 1|ringLevel1|ringLevel0|1|executeable|DC|RW|0
;flags2 = sizeInPages | 16or32bit | 0 | 0 | size 16..19
;if not sizeInPages then size is in bytes
gdtAddr:
;null table first
dd 0, 0

;text section
dw 0xFFFF	;size 0..15
dw 0		;base addr 0..15
db 0		;addr 16..23
db 10011010b;accessFlags
db 11001111b;flags2 and size 16..19
db 0		;addr 24..31

;data section
dw 0xFFFF	;size 0..15
dw 0		;addr 0..15
db 0		;addr 16..23
db 10010010b;accessFlags
db 11001111b;flags2 and size 16..19
db 0		;addr 24..31

gdtDescriptor:
dw gdtDescriptor - gdtAddr - 1 ;size
dd gdtAddr	;offset



;BOOT-LOADER STUFF
times 510 - ($-$$) db 0 ; fill rest of bootloader with zeroes	
;last two bytes of boot sector are boot signature
db 0x55
db 0xAA
