#!/bin/sh
dpkg -l | grep x11-repo && echo x11 repo installed || pkg install x11-repo
command -v vncserver && echo VNC installed || pkg add tiger-vnc
command -v fluxbox && echo Fluxbox installed || pkg add fluxbox
export DISPLAY=":1" 
pgrep Xvnc && echo VNC  Running || vncserver
pgrep fluxbox && echo Fluxbox running || fluxbox 
killall Xvnc
