#!/bin/bash

_GNARLY_DEBUG=0

_gdebug() {
  if [ $_GNARLY_DEBUG != 0 ]; then
    echo "$@"
  fi
}

_gnarly_command() {
  _gdebug "NOPE: $@"
  _GNARLY_CMD=$1
  fghj
}

command_not_found_handle() {
  _gdebug "--- begin handler ---"

  if (( ! IN_CNFH++)); then
    _gnarly_command $@
    (( IN_CNFH-- ))
  else
    echo "gnarly command '$_GNARLY_CMD' failed"
    echo "command not found: $1"
    (( IN_CNFH-- ))
    return 127
  fi

  _gdebug "--- end handler ---"
}
