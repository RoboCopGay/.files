#!/bin/sh

# sourced at boot by ~/.xinitrc and most display managers

export XDG_CONFIG_HOME="$HOME/.config"

# add additional directories to PATH
for dir in /sbin /usr/sbin "$HOME/bin"; do
	[ -d "$dir" ] && PATH="$dir:$PATH"
done

# compton
compton -b &

# restore the background
nitrogen --restore &

# keyring and polkit daemons
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon --start --components=pkcs11 &

# dpms: timeout sleep off
xset dpms 600 900 1200

# keyboard repeat rate
xset r rate 350 60

export QT_QPA_PLATFORMTHEME=gtk2
