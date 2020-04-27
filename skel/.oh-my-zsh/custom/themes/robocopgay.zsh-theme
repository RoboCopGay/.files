_robocopwd () {
  echo $(pwd | perl -pe '
   BEGIN {
      binmode STDIN,  ":encoding(UTF-8)";
      binmode STDOUT, ":encoding(UTF-8)";
   }; s|^$ENV{HOME}|~|g; s|/([^/.])[^/]*(?=/)|/$1|g; s|/\.([^/])[^/]*(?=/)|/.$1|g
')
}

PROMPT=" $(hostname.sh)%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})"
PROMPT+='$(_robocopwd)%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}%{$fg[yellow]%} !"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
