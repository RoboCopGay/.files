#!/bin/sh

# sourced at boot by ~/.xinitrc and most display managers

export XDG_CONFIG_HOME="$HOME/.config"

# add additional directories to PATH
for dir in /sbin /usr/sbin "$HOME/bin"; do
	[ -d "$dir" ] && PATH="$dir:$PATH"
done

# dpms: timeout sleep off
xset dpms 600 900 1200

# keyboard repeat rate
xset r rate 350 60

export QT_QPA_PLATFORMTHEME=qt5ct
