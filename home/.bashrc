# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

alias dbms="docker exec -e MYSQL_PWD=root mariadb-lab mysql -uroot dbms_lab"

# NPM global bin
export PATH="$HOME/.npm-global/bin:$PATH"
if command -v npm &>/dev/null; then
    export PATH="$(npm config get prefix)/bin:$PATH"
fi
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
