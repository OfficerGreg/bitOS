
#make os
OS: boot_sector.bin file_table.bin kernel.bin calculator.bin

#make boot_sector
#boot_sector:
	fasm ../src/boot_sector.asm
	mv ../src/boot_sector.bin ./
	
#make kernel
#kernel:
	fasm ../src/kernel.asm
	mv ../src/kernel.bin ./


#make file_table
#file_table:
	fasm ../src/file_table.asm
	mv ../src/file_table.bin ./

	fasm ../src/calculator.asm
	mv ../src/calculator.bin ./

	cat boot_sector.bin file_table.bin kernel.bin calculator.bin > bitOS.bin
clean:
	rm *.bin
