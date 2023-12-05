#!/bin/bash

cat >> ~/.bashrc << EOF
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias l='ls -lh --color=auto'

alias his='history'

alias tailf='tail -f'

alias psef='ps -ef | grep'
alias psaux='ps -aux | grep'

alias port='netstat -tunple | grep'

alias ~='cd ~'
alias ..='cd ..'
alias cd..='cd ..'

alias gitignore='git update-index --assume-unchanged'
alias noignore='git update-index --no-assume-unchanged'
EOF