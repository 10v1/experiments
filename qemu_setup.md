# Install QEMU
```bash
# choose a place to clone qemu repo
git clone 'https://gitlab.com/qemu-project/qemu.git'
cd qemu
git checkout v7.0.0

# after fix icv_access bug and patch virt.c/virt.h
mkdir build
cd build

# install binaries in install path
export QEMU_INSTALL_PATH=~/bin/qemu-upstream

../configure \
  --target-list=aarch64-softmmu \
  --prefix="$QEMU_INSTALL_PATH"
  
make -j $(nproc)
mkdir -p "$QEMU_INSTALL_PATH"
make install

# add QEMU_INSTALL_PATH to system path
```
# Edit makefile
```bash
# find qemutest.mk in this repo, move it to twinvisor-prototype/build
rm Makefile
ln -sf qemutest.mk Makefile
```
# Start scripts
```bash
# in /twinvisor-prototype/ dir
mkdir start
cd start
ln -sf ../trusted-firmware-a/build/qemu/release/bl1.bin bl1.bin
ln -sf ../trusted-firmware-a/build/qemu/release/bl2.bin bl2.bin
ln -sf ../trusted-firmware-a/build/qemu/release/bl31.bin bl31.bin
ln -sf ../s-visor/build/s_visor.bin bl32.bin
ln -sf ../edk2/Build/ArmVirtQemuKernel-AARCH64/RELEASE_GCC49/FV/QEMU_EFI.fd bl33.bin
ln -sf ../trusted-firmware-a/build/qemu/release/fip.bin fip.bin
ln -sf ../s-visor/build/s_visor.bin s_visor.bin
ln -sf ../s-visor/build/s_visor.img s_visor.img
ln -sf ../out-br/images/rootfs.cpio.gz rootfs.cpio.gz
ln -sf ../linux/arch/arm64/boot/Image Image

#find easysetup.mk in this repo, move it here
ln -sf easysetup.mk Makefile

```
# Start TF-A and s-visor
```bash
# after edit TF-A and s-visor source code, re-compile and run
# recompile, in twinvisor-prototype/build
# "testclean" option only remove and re-compile s-visor and atf, edk2 compile one time is enough
# make edk2
make testclean
# run, in twinvisor-prototype/start
make all
# you can use other options, refer to easysetup.mk

```
