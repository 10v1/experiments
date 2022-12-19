# TwinVisor Prototype
参考，以下为在Ubuntu 20.04上的复现流程。

---

## Prerequisite
update & install
```bash
sudo apt-get update
sudo apt-get install android-tools-adb android-tools-fastboot autoconf \
        automake bc bison build-essential cmake ccache codespell \
        cscope curl device-tree-compiler \
        expect flex ftp-upload gdisk iasl libattr1-dev libcap-dev \
        libfdt-dev libftdi-dev libglib2.0-dev libgmp-dev libhidapi-dev \
        libmpc-dev libncurses5-dev libpixman-1-dev libssl-dev libtool make \
        mtools netcat ninja-build python-crypto python3-crypto python-pyelftools \
        python3-pycryptodome python3-pyelftools python3-serial python \
        rsync unzip uuid-dev xdg-utils xterm xz-utils zlib1g-dev
```
## Setup
Clone TwinVisor repo
```bash
# clone main repo and submodules
git clone --recursive https://github.com/TwinVisor/twinvisor-prototype.git
cd twinvisor-prototype/
export TV_ROOT=$(pwd)

# check
ls $TV_ROOT/build/
```
Download [FVP Base](https://ipads.se.sjtu.edu.cn:1313/f/73e2572b19a24b32817c/?dl=1) and extract to FVP_Base_RevC-2xAEMv8A in $TV_ROOT directory.
```bash
# MD5: 0bd25ec5005c600d6f9b8ebc41aff0ab  FVP_Base_RevC-2xAEMv8A.tar.gz
wget -c https://ipads.se.sjtu.edu.cn:1313/f/73e2572b19a24b32817c/?dl=1 -O $TV_ROOT/FVP_Base_RevC-2xAEMv8A.tar.gz

tar xzf $TV_ROOT/FVP_Base_RevC-2xAEMv8A.tar.gz -C $TV_ROOT/
```
Get toolchains for aarch64/32 and disk image of the prototype. 
```bash
# from $TV_ROOT change to $TV_ROOT/build
cd $TV_ROOT/build

# download toolchains. it takes a while
make toolchains -j2

# there should have files in $TV_ROOT/toolchains and $TV_ROOT/toolchains/aarch64
ls ../toolchains
ls ../toolchains/aarch64

# download disk image
mkdir -p ../out
# The tarball is about 8GB, and the disk image after decompressed is about 40GB
# MD5: c16d78505fa16a8520ee08a05d1debf7  boot.tar.gz
wget -c https://ipads.se.sjtu.edu.cn:1313/f/73350e5ff3e440a98081/?dl=1 -O ../out/boot.tar.gz

tar xzf ../out/boot.tar.gz -C ../out

# Test boot.img and the guest kernel image
ls ../out/boot.img
ls ../out/Image
```
Compile all and run.
```bash
make all -j$(nproc)
make run-only
```
FVP，FVP terminal 0和FVP terminal 1将会启动，FVP terminal 0是host linux(N-Visor)，等启动完成就可以以用户名`root`登录。接下来挂载rootfs和chroot
```bash
mount /dev/vda2 /root
chroot /root bash
./init.sh
```
![image.png](https://cdn.nlark.com/yuque/0/2022/png/28021771/1671448311514-1f968c9b-3bdd-4bce-a4ae-70e050922430.png#averageHue=%23141414&clientId=u5546e5e0-a0db-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=395&id=u870ef42e&margin=%5Bobject%20Object%5D&name=image.png&originHeight=790&originWidth=1050&originalType=binary&ratio=1&rotation=0&showTitle=false&size=230484&status=done&style=none&taskId=u14da8c9e-f920-485d-aed7-b04c286de19&title=&width=525)
然后在test目录中启动s-vm，上一步应该会自动切换到test目录。
```bash
# if not in /test
cd /test

./s-vm0.sh
```
然后在s-vm中挂载fs和chroot。
```bash
mount /dev/vda /root
chroot /root bash

# some example in guest rootfs' /test directory
./fileio.sh
```
