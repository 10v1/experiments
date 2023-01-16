# Install QEMU
```bash
# choose a place to clone qemu repo
git clone 'https://gitlab.com/qemu-project/qemu.git'
cd qemu
git checkout v7.0.0

# after fix icv_access bug and patch virt.c/virt.h
mkdir build

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
# in /twinvisor-prototype dir
mkdir softlinks
cd softlinks
ln -sf ../trusted-firmware-a/build/qemu/release/bl1.bin bl1.bin
ln -sf ../trusted-firmware-a/build/qemu/release/bl2.bin bl2.bin
ln -sf ../trusted-firmware-a/build/qemu/release/bl31.bin bl31.bin
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
# after edit TF-A and s-visor source code, recompile and run
# recompile, in twinvisor-prototype/build
make testclean
# run, in twinvisor-prototype/softlinks
make all

```
