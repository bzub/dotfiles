#!/usr/bin/env sh
set -e

name="${1}"
if [ -z "${1}" ]; then
  name="main"
fi

export SHELL="/usr/local/bin/zsh"
export EDITOR="nvim"
cd "${HOME}/ghq"
/usr/local/bin/abduco -A -e '˝' "${name}" "/usr/local/bin/nvim" "-V1"
