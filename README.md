# Installation
## tmux
* Install [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
* Copy .tmux.conf and .tmux.conf.local to home directory
```
$ wget https://raw.githubusercontent.com/frazrepo/dotfiles/master/.tmux.conf && wget https://raw.githubusercontent.com/frazrepo/dotfiles/master/.tmux.conf.local
```
## vim 
* Find instructions here [https://github.com/frazrepo/vimrc](https://github.com/frazrepo/vimrc)

## neovim
* Find instructions here https://github.com/frazrepo/nvim-config

## zsh
* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/) or [prezto](https://github.com/sorin-ionescu/prezto)

And add hostname for zsh

```
  PROMPT='%{$fg_bold[white]%}%M %{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'
```

# Credits
* [tmux](https://github.com/gpakosz/.tmux)
