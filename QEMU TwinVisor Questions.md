# Modifications
目前只对进行了几处修改，ATF映射空间、qemu virt.c还没动过：
```bash
TF_A_FLAGS ?= \
	BL32=$(S_VISOR_IMAGE) \
	BL33=$(EDK2_BIN) \
	ARM_TSP_RAM_LOCATION=tdram \
	BL32_RAM_LOCATION=tdram \
	QEMU_USE_GIC_DRIVER=QEMU_GICV3 \
	PLAT=qemu \
	SPD=opteed \
  DEBUG=0 \
  MBEDTLS_DIR=$(ROOT)/mbedtls  \
  ARM_ROTPK_LOCATION=devel_rsa \
  GENERATE_COT=1 \
  MEASURED_BOOT=1 \
  ROT_KEY=plat/arm/board/common/rotpk/arm_rotprivk_rsa.pem \
  TPM_HASH_ALG=sha256 \
  TRUSTED_BOARD_BOOT=1 \
  EVENT_LOG_LEVEL=20

# Add line 5: BL32_RAM_LOCATION=tdram
# Original line 6: FVP_USE_GIC_DRIVER=FVP_GICV3
# Original line 7: PLAT=fvp
```
```bash
define edk2-call
	$(EDK2_TOOLCHAIN)_$(EDK2_ARCH)_PREFIX=$(AARCH64_CROSS_COMPILE) \
	build -n `getconf _NPROCESSORS_ONLN` -a $(EDK2_ARCH) \
		-t $(EDK2_TOOLCHAIN) -p ArmVirtPkg/ArmVirtQemuKernel.dsc -b $(EDK2_BUILD)
endef

# Original -p Platform/ARM/VExpressPkg/ArmVExpress-FVP-AArch64.dsc
```
```bash
# copy files to a ramdisk image
#......
sudo cp $(LINUX_PATH)/arch/arm64/boot/dts/arm/virt.dtb $(RAMDISK_MNT_PATH)
sudo cp $(LINUX_PATH)/arch/arm64/boot/dts/arm/foundation-v8-gicv3-psci.dtb $(RAMDISK_MNT_PATH)
#......

# virt.dtb: dumped from qemu
```

# Result
```bash
qemu-system-aarch64 -nographic \
	-M virt,secure=on -cpu max \
	-kernel Image -no-acpi -initrd rootfs.cpio.gz \
	-smp 2 -m 2048 \
	-bios flash.bin \
	-d int -D ./test.txt
```
> 最终卡在BL31->BL32
> NOTICE:  Booting Trusted Firmware
> NOTICE:  BL1: v2.5(release):ca4f1fc
> NOTICE:  BL1: Built : 22:04:20, Dec 25 2022
> NOTICE:  BL1: Booting BL2
> NOTICE:  BL2: v2.5(release):ca4f1fc
> NOTICE:  BL2: Built : 22:04:20, Dec 25 2022
> NOTICE:  BL1: Booting BL31
> NOTICE:  BL31: v2.5(release):ca4f1fc
> NOTICE:  BL31: Built : 22:04:20, Dec 25 2022
> 
> 记录到的interrupt/exception log
> Exception return from AArch64 EL3 to AArch64 EL1 PC 0xe01b000
> Taking exception 13 [Secure Monitor Call] on CPU 0
> ...from EL1 to EL3
> ...with ESR 0x17/0x5e000000
> ...with ELR 0xe01d4b4
> ...to EL3 PC 0x3400 PSTATE 0x3cd
> Exception return from AArch64 EL3 to AArch64 EL3 PC 0xe040000
> Taking exception 4 [Data Abort] on CPU 0
> ...from EL3 to EL3
> ...with ESR 0x25/0x96000010
> ...with FAR 0x800ffe8
> ...with ELR 0xe04212c
> ...to EL3 PC 0xe046000 PSTATE 0x3cd

```bash
qemu-system-aarch64 -nographic \
	-M virt,secure=on -cpu max \
	-kernel Image -no-acpi -initrd rootfs.cpio.gz \
	-smp 2 -m 2048 \
	-bios bl1.bin -semihosting-config enable=on,target=native \
	-d int -D ./test.txt
```
> BL2报错
> NOTICE:  Booting Trusted Firmware
> NOTICE:  BL1: v2.5(release):ca4f1fc
> NOTICE:  BL1: Built : 22:04:20, Dec 25 2022
> NOTICE:  BL1: Booting BL2
> NOTICE:  BL2: v2.5(release):ca4f1fc
> NOTICE:  BL2: Built : 22:04:20, Dec 25 2022
> ERROR:   BL2: Failed to load image id 4 (-2)
> 
> log有点多就不放了

有个疑问：

- 在QEMU上运行TwinVisor需不需要改使用的dtb等文件
