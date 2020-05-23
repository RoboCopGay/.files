#!/bin/zsh

echo "
                      ██████▒██▓ ██▓    ▓█████   ██████
                     ▓██   ▒▓██▒▓██▒    ▓█   ▀ ▒██    ▒
                     ▒████ ░▒██▒▒██░    ▒███   ░ ▓██▄
                     ░▓█▒  ░░██░▒██░    ▒▓█  ▄   ▒   ██▒
                 ██▓ ░▒█░   ░██░░██████▒░▒████▒▒██████▒▒
                 ▒▓▒  ▒ ░   ░▓  ░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░
                 ░▒   ░      ▒ ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░
                 ░    ░ ░    ▒ ░  ░ ░      ░   ░  ░  ░
                  ░          ░      ░  ░   ░  ░      ░
                  ░
 ██▓ ███▄    █   ██████ ▄▄▄█████▓ ▄▄▄       ██▓     ██▓    ▓█████  ██▀███
▓██▒ ██ ▀█   █ ▒██    ▒ ▓  ██▒ ▓▒▒████▄    ▓██▒    ▓██▒    ▓█   ▀ ▓██ ▒ ██▒
▒██▒▓██  ▀█ ██▒░ ▓██▄   ▒ ▓██░ ▒░▒██  ▀█▄  ▒██░    ▒██░    ▒███   ▓██ ░▄█ ▒
░██░▓██▒  ▐▌██▒  ▒   ██▒░ ▓██▓ ░ ░██▄▄▄▄██ ▒██░    ▒██░    ▒▓█  ▄ ▒██▀▀█▄
░██░▒██░   ▓██░▒██████▒▒  ▒██▒ ░  ▓█   ▓██▒░██████▒░██████▒░▒████▒░██▓ ▒██▒
░▓  ░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░  ▒ ░░    ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░░░ ▒░ ░░ ▒▓ ░▒▓░
 ▒ ░░ ░░   ░ ▒░░ ░▒  ░ ░    ░      ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░ ░ ░  ░  ░▒ ░ ▒░
 ▒ ░   ░   ░ ░ ░  ░  ░    ░        ░   ▒     ░ ░     ░ ░      ░     ░░   ░
 ░           ░       ░                 ░  ░    ░  ░    ░  ░   ░  ░   ░
"

dotfile_dir="$(realpath .)"

echo ":: Put your (sudo) password:"
sudo uname > /dev/null

die(){
    echo "$*" > /dev/stderr
    exit 1
}
[[ $(pacman -V) ]] || die ":: You have'nt the pacman package manager on your sytem
   Please, install it before run this script."

[[ "$(cat /etc/pacman.conf | grep "archlabs_repo")" == "" ]] && \
    sudo cp pacman.conf /etc/pacman.conf > /dev/null
echo ":: Downloading fresh package databases" && sudo pacman -Sy > /dev/null
echo ":: Installing the yay AUR Helper"
sudo pacman -U ./yay.pkg.tar.xz


installpackages(){
    echo -n ":: This script will to install all packages on 'packages.list'\n   Do you wanna to edit it? [y/N] " && read opc

    if [[ "$opc" == "y" || "$opc" == "Y" ]];then
        if [[ "$EDITOR" == '' ]];then
            echo -n ":: Put the command to your editor: (default= nano) " && read EDITOR
            [[ "$EDITOR" != '' ]] || EDITOR=nano
        fi
        ${EDITOR} "$dotfile_dir/packages.list" || die ":: This editor is not on system or failure"
    fi

    yay -S $(cat "$dotfile_dir/packages.list") --noconfirm --needed && echo ":: All packages installed" || die "[!] Did Some extern error, aborting..."
    pip install pynvim > /dev/null 2> /dev/null
}

installdotfiles(){
    echo ":: Making backup of your user folder on \"$HOME/.files_backup\"" && mkdir "$HOME/.files_backup"
    sudo touch "/etc/WORKSPACE" && echo 'casual' | sudo tee /etc/WORKSPACE
    sudo cp -rf "$HOME/{.bash_logout,.gitconfig,.xprofile,.bash_profile,.gitignore,.Xresources,.bashrc,.gtkrc-2.0,.zcompdump,bin/,.oh-my-zsh/,.zcompdump-RoboCopBook-5.8,.cache/,.python_history,.zprofile,.config/,.screenlayout/,.zsh/.fehbg,.tmux/,.zsh_history,.fzf/,.tmux.conf,.zshrc,.fzf.bash,.tmux-session,.zshrc_backup,.fzf.zsh,.wminit,.zshrc.pre-oh-my-zsh}" "$HOME/.files_backup"

    sudo cp -rf "$dotfile_dir/skel/*" "$dotfile_dir/skel/.*" "$HOME/"
    sudo rm -rf "$HOME/.git*"
}

if [[ $(cat .git/config | grep "RoboCopGay/dotfiles" 2> /dev/null ) ]] 2> /dev/null > /dev/null;then
    if [[ $(yay -V) ]];then
        installpackages
    else
        git clone http://git.archlinux.org/yay /tmp/yay && echo ':: Installing the AUR helper ( yay )' \
            || sudo pacman -S git --noconfirm || die '[!] You need to install "git" before'
                echo ":: Installed $($(yay -V | cur -d '-' -f 1) || die '[!] Yay not installed!')"
        cd /tmp/yay && makepkg -i --noconfirm -f && cd "$dotfile_dir"
        installpackages
    fi

    installdotfiles
else
    die '[!] You need to stay on dotfiles repository folder'
fi

