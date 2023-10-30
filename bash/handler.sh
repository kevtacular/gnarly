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
    cmd=$(yq .commands.$1.script $gnarly_cfg_file)
    if [ "$cmd" != "" ]; then
      # Read command args and set variables for each
      local i=0
      local arg=""
      local gcommand=$1
      while [ true ]; do
        arg=$(yq .commands.$gcommand.args[$i] $gnarly_cfg_file)
        if [ "$arg" = "null" ]; then
          break
        fi

        shift
        if [ "$1" = "" ]; then
          echo "Missing argument $arg for gnarly command '$gcommand'"
          return 1
        fi
        eval "$arg=$1"
        _gdebug "arg $arg=$1"

        ((i++))
      done
    else
      # Simple command with no args
      cmd=$(yq .commands.$1 $gnarly_cfg_file)
    fi
    _gdebug "command $_GNARLY_CMD resolved to: ${cmd}"
  fi

  if [ "$cmd" = "" ] || [ "$cmd" = "null" ]; then
    # No command to execute; treat as a normal shell "command not found"
    $@
  else
    # Execute the gnarly command script
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
