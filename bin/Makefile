
# Create the OS.bin file (use 'Make OS')
OS: boot_sector file_table kernel calculator
	cat boot_sector.bin file_table.bin kernel.bin calculator.bin > OS.bin

# Create bootsector binary file (use 'Make bootSect.bin')
boot_sector:
	fasm ../src/boot_sector.asm
	mv ../src/boot_sector.bin ./
	
# Create file table binary file (use 'Make fileTable.bin')
file_table:
	fasm ../src/file_table.asm
	mv ../src/file_table.bin ./

# Create kernel binary file (use 'Make kernel.bin')
kernel:
	fasm ../src/kernel.asm
	mv ../src/kernel.bin ./

calculator:
	fasm ../src/calculator.asm
	mv ../src/calculator.bin ./

# Clean up binary files (use 'Make clean')
clean:
	rm *.bin