#!/bin/sh

MEM=512
DISK_SIZE=8g

dpkg -l | grep unstable-repo && echo Unstable repo installed || pkg install unstable-repo
dpkg -l | grep x11-repo && echo x11 repo installed || pkg install x11-repo
command -v qemu-system-x86_64 && echo Qemu installed || pkg install qemu-systemr-x86_64
command -v qemu-img && echo Qemu utils installed || pkg install qemu-utils
command -v curl && echo Curl installed || pkg install curl
[ -e alpine.img ] && echo Disk exists || qemu-img create -f qcow2 alpine.img $DISK_SIZE
[ -e alpine.iso ] && echo Iso exists ||  curl http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64/alpine-virt-3.10.1-x86_64.iso -o alpine.iso
# wild guess if installed was done based on disk size
qemu-img info alpine.img | grep disk | grep M && echo Alpine setup || qemu-system-x86_64 -hda alpine.img -cdrom alpine.iso -boot d -m $MEM
qemu-system-x86_64 -hda alpine.img -boot c -m $MEM

