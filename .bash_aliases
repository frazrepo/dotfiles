
# Useful aliases
alias v=vim
alias nv=nvim
alias tm=tmux
alias ..='cd ..'
alias c='clear'
alias install='sudo apt install'
alias remove='sudo apt remove'


# docker
alias dockershell="docker run --rm -i -t --entrypoint=/bin/bash"  
alias dockershellsh="docker run --rm -i -t --entrypoint=/bin/sh"

function dockershellhere() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}
function dockershellshhere() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}
