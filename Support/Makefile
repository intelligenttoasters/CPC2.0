all: build1

.SILENT: build1 build2 upload

clean:
	rm -rf build
	mkdir build

build1: 
	$(MAKE) -C build -f ../Makefile build2

# Build the supervisor code	
build2: next_build_no
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/main.c
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/library/library.c
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/spi/spi.c
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/stdio_spi/stdio_spi.c
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/interrupt.c
	sdcc --no-std-crt0 -mz80 -c --debug -I ../include ../src/hdmi/hdmi.c
	sdasz80 -l -o -s -y _boot.rel ../asm/_boot.asm
	
	# Note that _BOOT.REL must be first to correctly set the ordering of the initialized data area
	sdldz80 -m -i -y -k /usr/share/sdcc/lib/z80 -l z80.lib rom.ihx `ls *.rel|sort`
	
	# Check for overlapping code sections
	srec_cat rom.ihx -intel -o rom.hex -intel
	
	# Now create the ROM	
	echo "Creating output files, bin / mif / hex"
	makebin -s 65536 rom.ihx > ROM.bin
	../scripts/make_mif ROM
	../scripts/make_hex ROM

upload:
	echo "Uploading to FPGA"
	scripts/quartus_upload

sim:
	cat scripts/z80-mon.header build/ROM.bin > build/ROM.z80
	z80-mon build/ROM.z80
	
debug:
	$(MAKE) -C build -f ../Makefile debug1
	
debug1:
	sdcdb -mz80 -t z80 --directory=../src --directory=../src/spi --directory=../src/stdlib --directory=../src/stdio --directory=../include rom
	
next_build_no:
	../buildnum.sh