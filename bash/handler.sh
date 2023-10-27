#!/bin/bash

_GNARLY_DEBUG=0

_gdebug() {
  if [ $_GNARLY_DEBUG != 0 ]; then
    echo "$@"
  fi
}

_gnarly_check_yq() {
  if [ ! -x "$(command -v yq)" ]; then
    echo "command not found: $1"
    echo "WARN: ensure yq is in the PATH to use gnarly commands"
    return 1
  fi
  return 0
}

_gnarly_find_cfg_file() {
  local dir=$(realpath $PWD)
  while [ true ]; do
    if [ "$dir" = "" ]; then
      gnarly_cfg_file=""
      break
    else
      gnarly_cfg_file="$dir/.gnarly/bash.yml"
      if [ -f "$gnarly_cfg_file" ]; then
        break
      fi
      dir=${dir%/*}
    fi
  done
}

_gnarly_command() {
  local cmd=""

  _GNARLY_CMD=$1

  # lookup the command in bash.yml
  _gnarly_find_cfg_file
  if [ "$gnarly_cfg_file" != "" ]; then
    cmd=$(yq .commands.$1 $gnarly_cfg_file)
    _gdebug "command $1 resolved to: ${cmd}"
  fi

  if [ "$cmd" = "" ] || [ "$cmd" = "null" ]; then
    $@
  else
    eval "${cmd}"
  fi
}

command_not_found_handle() {
  _gdebug "--- begin handler ---"

  if (( ! IN_CNFH++)); then
    _gnarly_check_yq $1
    if [ "$?" = 0 ]; then
      _gnarly_command $@
    fi
    (( IN_CNFH-- ))
  else
    # a gnarly subcommand was not found
    echo "command not found: $1"
    (( IN_CNFH-- ))
    return 127
  fi

  _gdebug "--- end handler ---"
}
