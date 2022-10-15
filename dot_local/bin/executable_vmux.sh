#!/usr/bin/env bash
set -e

name="${1}"
if [ -z "${1}" ]; then
  name="main"
fi

export SHELL="/usr/local/bin/zsh"
export EDITOR="nvim"
cd "${HOME}/ghq"
/usr/local/bin/abduco -f -A -e '˝' "${name}" "/usr/local/bin/nvim" "-V1"
