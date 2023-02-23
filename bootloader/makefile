all:
	nasm bootloader.asm -f bin -o build/boot.bin
	
	#create floppy bootloader
	dd if=/dev/zero of=build/floppy.img bs=512 count=2880
	dd if=build/boot.bin of=build/floppy.img conv=notrunc
	
remove:
	rm build/floppy.img
	rm build/boot.bin
