#!/bin/bash

# Overridable Settings
if [ -z "${GNARLY_DEBUG+x}" ]; then
    GNARLY_DEBUG=${GNARLY_DEBUG:-0}
fi

if [ -z "${GNARLY_FILENAME+x}" ]; then
    GNARLY_FILENAME=".gnarly.yml"
fi

if [ -z "${GNARLY_PATH+x}" ]; then
    GNARLY_PATH="$HOME"
fi

# Fixed Settings - do not override these outside of gnarly.sh
if [ -z "${GNARLY_HOME+x}" ]; then
    readonly GNARLY_HOME=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
fi

# Error codes
if [ -z "${E_SUCCESS+x}" ]; then
    readonly E_SUCCESS=0
fi

if [ -z "${E_COMMAND_NOT_FOUND+x}" ]; then
    readonly E_COMMAND_NOT_FOUND=127
fi

if [ -z "${E_INVALID_ARGS+x}" ]; then
    readonly E_INVALID_ARGS=1
fi

if [ -z "${E_CONFIG_NOT_FOUND+x}" ]; then
    readonly E_CONFIG_NOT_FOUND=2
fi

if [ -z "${E_YQ_NOT_FOUND+x}" ]; then
    readonly E_YQ_NOT_FOUND=3
fi

# Debug logging
_gdebug() {
    if [ "$GNARLY_DEBUG" != 0 ]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Error logging
_gerror() {
    echo "[ERROR] $*" >&2
}

# Check if yq is installed and available
_gnarly_check_yq() {
    if ! command -v yq >/dev/null 2>&1; then
        _gerror "yq is required but not found in PATH"
        return $E_YQ_NOT_FOUND
    fi
    return $E_SUCCESS
}

# Find the nearest gnarly config file by traversing up the directory tree
_gnarly_find_cfg_file() {
    local dir
    dir=$(realpath "$PWD")
    
    while [ -n "$dir" ] && [[ "$dir" == "$GNARLY_PATH"* ]]; do
        local cfg_file="$dir/$GNARLY_FILENAME"
        if [ -f "$cfg_file" ]; then
            GNARLY_CFG_DIR=$dir
            GNARLY_CFG_FILE=$cfg_file
            _gdebug "GNARLY_CFG_DIR=$GNARLY_CFG_DIR"
            _gdebug "GNARLY_CFG_FILE=$GNARLY_CFG_FILE"
            return $E_SUCCESS
        fi
        dir=${dir%/*}
    done
    
    GNARLY_CFG_FILE=""
    return $E_CONFIG_NOT_FOUND
}

# Validate command arguments against the config
_gnarly_validate_args() {
    local cmd=$1
    shift
    
    # First check if the command has an args array defined
    local args_type
    args_type=$(yq ".commands.$cmd.args | type" "$GNARLY_CFG_FILE")
    _gdebug "Command '$cmd' args type: $args_type"
    if [ "$args_type" != "!!seq" ] && [ "$args_type" != "array" ]; then
        return $E_SUCCESS
    fi
    
    local i=0
    local arg
    while true; do
        arg=$(yq ".commands.$cmd.args[$i]" "$GNARLY_CFG_FILE")
        [ "$arg" = "null" ] && break
        
        if ! [[ "$arg" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            _gerror "Invalid argument name '$arg' for command '$cmd'"
            return $E_INVALID_ARGS
        fi
        
        if [ $# -eq 0 ]; then
            _gerror "Missing required argument '$arg' for command '$cmd'"
            return $E_INVALID_ARGS
        fi
        eval "$arg=$1"
        _gdebug "Setting argument $arg=$1"
        shift
        ((i++))
    done
    
    return $E_SUCCESS
}

# Execute a gnarly command
_gnarly_command() {
    local cmd=""
    local gcommand=$1
    shift
    
    _gnarly_find_cfg_file || {
        _gdebug "No gnarly configuration found"
        _gdebug "--- end handler ---"
        return $E_CONFIG_NOT_FOUND
    }
    
    # Try to get script first
    cmd=$(yq ".commands.$gcommand.script" "$GNARLY_CFG_FILE")
    
    if [ "$cmd" = "null" ] || [ -z "$cmd" ]; then
        # Fall back to simple command
        cmd=$(yq ".commands.$gcommand" "$GNARLY_CFG_FILE")
    fi
    
    if [ "$cmd" = "null" ] || [ -z "$cmd" ]; then
        return $E_COMMAND_NOT_FOUND
    fi
    
    # Validate arguments if present
    _gnarly_validate_args "$gcommand" "$@" || return $?
    
    _gdebug "Executing command: $cmd"
    eval "$cmd"
}

# How gnarly handles commands that are not found in its configuration
command_not_found_fallback() {
    if [ -x "/usr/lib/command-not-found" ]; then
        /usr/lib/command-not-found "$@"
    else
        echo "$1: command not found"
    fi
}

# Command not found handler - this is gnarly's main entry point for handling commands that are not found by bash
command_not_found_handle() {
    local status
    _gdebug "--- begin handler ---"
    
    # Prevent infinite recursion
    if (( ! IN_CNFH++ )); then
        _gnarly_check_yq || {
            status=$E_YQ_NOT_FOUND
            _gdebug "--- end handler ---"
            return $status
        }
        _gnarly_command "$@"
        status=$?
        if [ "$status" -eq "$E_CONFIG_NOT_FOUND" ] || [ "$status" -eq "$E_COMMAND_NOT_FOUND" ]; then
            command_not_found_fallback "$@"
        fi
        (( IN_CNFH-- ))
        _gdebug "--- end handler ---"
        return $status
    else
        (( IN_CNFH-- ))
        status=$E_COMMAND_NOT_FOUND
        _gdebug "--- end handler ---"
        return $status
    fi
}

# List available commands
_gnarly_verbose() {
    if [ ! -f "$GNARLY_CFG_FILE" ]; then
        _gerror "No gnarly configuration found"
        return $E_CONFIG_NOT_FOUND
    fi
    
    yq e '.commands | to_entries() | .[] | ((select(.value.script == null) | .key + ": " + (.value | split("\n") | .[0])), (select(.value.script != null) | .key + ": [script]"))' "$GNARLY_CFG_FILE" | sort
}

# Initialize a new gnarly configuration
_gnarly_init() {
    if [ -f "$GNARLY_FILENAME" ]; then
        _gerror "File $GNARLY_FILENAME already exists"
        return $E_INVALID_ARGS
    fi
    
    echo "Creating $GNARLY_FILENAME"
    cat << EOF > "$GNARLY_FILENAME"
# =============================================================================
# List your gnarly commands in one of the following formats:
#
# 1. Simple command
# 
#    commands:
#      gecho: echo "gecko"
#
# 2. Command with script and optional arguments
#
#    commands:
#      showfs:
#        args:
#          - G_FILE
#        script: |
#          echo "=== File System Info ==="
#          df -h --output \$G_FILE
#
# =============================================================================
commands:
  gecho: echo "gecko"
EOF
}

# Show command definition
_gnarly_show() {
    local cmd=$1
    local cmd_def
    
    if [ ! -f "$GNARLY_CFG_FILE" ]; then
        _gerror "No gnarly configuration found"
        return $E_CONFIG_NOT_FOUND
    fi
    
    cmd_def=$(yq ".commands.$cmd" "$GNARLY_CFG_FILE")
    if [ "$cmd_def" = "null" ]; then
        _gerror "Command not found: $cmd"
        return $E_COMMAND_NOT_FOUND
    fi
    
    echo "$cmd_def"
}

# Display help message
_gnarly_help() {
    cat << EOF
Usage: gnarly [OPTION] [COMMAND]

Gnarly is a tool for managing project-specific shell aliases defined in YAML files.

Options:
  -v, --verbose   List all available commands with descriptions
  --version       Show gnarly version
  -h, --help      Display this help message

Commands:
  init            Initialize the current directory with a .gnarly.yml file
  show <command>  Show the definition of a specific gnarly command

If no command or option is provided, gnarly will list all available commands.

Examples:
  gnarly
  gnarly init
  gnarly show mycommand
  gnarly -v
  gnarly --version
  gnarly -h
  gnarly --help
EOF
}

# Main gnarly command
gnarly() {
    _gnarly_find_cfg_file
    
    case "$1" in
        --version)
            local version
            version=$(cat "$GNARLY_HOME/VERSION")
            echo "gnarly (https://github.com/kevtacular/gnarly) version v$version"
            ;;
        -v|--verbose)
            _gnarly_verbose
            ;;
        init)
            _gnarly_init
            ;;
        show)
            if [ $# -lt 2 ]; then
                _gerror "Usage: gnarly show <command>"
                return $E_INVALID_ARGS
            fi
            _gnarly_show "$2"
            ;;
        -h|--help)
            _gnarly_help
            ;;
        "")
            if [ -f "$GNARLY_CFG_FILE" ]; then
                yq '.commands.* | key' "$GNARLY_CFG_FILE"
            else
                _gerror "No gnarly commands found"
                return $E_CONFIG_NOT_FOUND
            fi
            ;;
        *)
            _gerror "Usage: gnarly [init | show <command> | --verbose | --version | --help]"
            return $E_INVALID_ARGS
    esac
}