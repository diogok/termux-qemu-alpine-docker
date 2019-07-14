# Termux + Qemu + Alpine + Docker + VNC

This is a setup for runing docker on android, by the means of Termux, running alpine in qemu and them enabling docker on the Alpine.

This was only tested on Samsung S10e.

## [Install Termux](https://termux.com)

And start it.

## Setup VNC + Fluxbox

First step was to setup VNC and Fluxbox, which is quite easy following [termux VNC guide](https://wiki.termux.com/wiki/Graphic_Environment):

Enable x11 repository, install tiger-vnc and fluxbox:

```
pkg install x11-repo
pkg install tigervnc fluxbox
```

Them start vncserver, it will ask you to setup password and other options, just follow on screen instructions:

```
vncserver
```

Xvnc will them be running in background. We can now start fluxbox:

```
DISPLAY=":1" fluxbox
```

This will start fluxbox on the Xvnc server and lock the current terminal. You can also append an "&" on that command to start it in background.

You can stop fluxbox on the remote desktop.

You can stop vnc:

```
vncserver -kill :1
```

To access your VNC server, choose your RDP client (like Vinagre on Ubuntu, or VNC Viewer on Android) and connect to your phone IP on port 5901 (for display :1).

To discover your phone IP on the wifi:

```
ip addr show wlan0
```

Inside Fluxbox you can right-click on the desktop to get a menu and launch stuff like "aterm".

## Setup QEMU

Qemu setup is quite easy, just small gotcha is that I had to use qemu from x11-repo instead of unstable headless, and do not really know why.

Installing Qemu:

```
pkg install unstable-repo
pkg install qemu-system-x64_64 qemu-utils
```

That is it.

## Preparing to install Alpine on Qemu

You will need the Alpine *virtual* ISO, that you can download from [alpine website](https://alpinelinux.org). Save it as alpine.iso to easy the typing:

```
pkg install curl
curl http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64/alpine-virt-3.10.1-x86_64.iso -o alpine.iso
```

Them you will need an image disk for the alpine installation to reside in:

```
qemu-img create -f qcow2 alpine.img 5g
```

## Starting Alpine installation on QEMU

Them you can launch Qemu installation of Alpine. I fyou are on an XVNC session, it will launch a QEMU window.

```
qemu-system-x86_64 -hda alpine.img -cdrom alpine.iso -boot d -m 512
```

If you want to keep on the same terminal (not launching a new window) you can append "-nographic" to that last command.

If you are on a QEMU window you can click it to grab focus, and can CTRL+ALT+G to release focus. You can also CTRL+ALT+F to go fullscreen.

On a terminal, you can stop emulation with CTRL+A+X. There are several others Ctrl+A commands.

It will take a while for alpine to boot, but will them present you with a "Login:" terminal, just enter "root" to start. 

## Setting up networking on Alpine on Qemu

This is a part that I had trouble, before starting setup inside alpine, you should setup proper network.

First, setup the interfaces, by editing */etc/network/interfaces* to have the following content:

```
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
```

Save it, and restart the alpine network:

```
/etc/init.d/networking restart
```

You should get an IP from the Qemu user network. Please be aware that _ping_ does not work on this setup.

Them, and only them, you also need to add DNS servers, by editing */etc/resolv.conf* to the following:

```
nameserver 8.8.8.8
```

You can test by trying to setup just the repositories:

```
setup-apkrepos
```

If this gives you a list of repos to choose from (About 40+), them it worked.

## Installing Alpine

To start installation:

```
setup-alpine
```

Just follow on screen instructions with attention. Be sure to choose to install on disk "sda" when prompted.

Once the installation is complete, shutdown Alpine by issuing halt"

```
halt
```

When it says system halted, exit Qemu (either by CTRL+Alt+g and closing window, or by ctrl+a+x on the terminal).


## Running installed Alpine on Qemu

To start alpine, simply run:

```
qemu-system-x86_64 -hda alpine.img -boot c -m 512
```

It will be take a while and give you a login prompt for the root user you setup.

## Installing Docker on Alpine

The reason I installed it all is to [run docker on alpine](https://wiki.alpinelinux.org/wiki/Docker).

On alpine, edit /etc/pkg/repositories and uncomment comunity repository, them install docker:

```
apk update
apk add docker
```

Start the service and enable it on boot:

```
service start docker
update-rc enable docker
```

Test it out

```
docker info
docker run alpine echo hello
```

## How slow is it?

On my machine a simple hello world take 1s to echo, while on this setup it takes 25s. Well, at least it works...

