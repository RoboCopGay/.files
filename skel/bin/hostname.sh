hostname=$(echo "$([[ $(whoami) != robocopgay ]] && echo "$(whoami)" )$([[ $(cat /etc/WORKSPACE) != casual ]] && echo "\033[1;3;37m@\033[00m$(cat /etc/WORKSPACE)\n " || echo ' ')")

python -c "from sys import stdout;stdout.write('$hostname' if '@' in '$hostname' else '$hostname\n' if '$hostname'.strip() != '' else '')"
