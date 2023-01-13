rmflash:
	rm flash.bin

mkflash:
	dd if=bl1.bin of=flash.bin bs=4096 conv=notrunc
	dd if=fip.bin of=flash.bin bs=4096 seek=64 conv=notrunc

qemustart:
	qemu-system-aarch64 -nographic \
                -smp 4 \
		-monitor tcp:localhost:1234,server,nowait \
                -machine virt,secure=on,mte=off,gic-version=3,virtualization=on \
                -cpu max,sve=off \
                -d int -D ./int.log \
                -m 3054,slots=1,maxmem=4G \
                -bios flash.bin \
                -initrd rootfs.cpio.gz \
                -kernel Image -no-acpi
qemucpulog:
	qemu-system-aarch64 -nographic \
                -smp 4 \
                -machine virt,secure=on,mte=off,gic-version=3,virtualization=on \
                -cpu max,sve=off \
                -d cpu -D ./cpu.log \
                -m 3054,slots=1,maxmem=4G \
                -bios flash.bin \
                -initrd rootfs.cpio.gz \
                -kernel Image -no-acpi
all: rmflash mkflash qemustart
