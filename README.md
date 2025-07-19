# GNARLY - A Gnarlier Alias

## Installation

To install gnarly, you can use the `install.sh` script.

```bash
$ curl -sSL https://raw.githubusercontent.com/kevtacular/gnarly/main/scripts/install.sh | bash
```

This will install `gnarly` to `~/.gnarly` and add a line to your `.bashrc` to source the script. You will need to open a new terminal session or run `source ~/.bashrc` for the changes to take effect.

## Overview

Gnarly is similar to the aliases commonly used in shells such as bash, but the
alias definitions are stored in YAML files.

_NOTE: Gnarly currently supports only the bash shell. It requires the
[yq](https://github.com/mikefarah/yq/#install) utility to be installed and on
the `$PATH`._

Gnarly works by defining a shell _hook_ that gets called whenever a command is
not found. For example, if you try to execute this command in your bash shell,
the shell will not likely find a matching executable:

```bash
$ gecho
command not found: gecho
```

With gnarly, we can define this command in a `.gnarly.yml` file like so:

```yaml
commands:
  gecho: echo "gecko"
```

Now, when the bash shell can't find a `gecho` executable, it calls the gnarly
hook (a function named `command_not_found_handle()`), which finds this command
in the `.gnarly.yml` file and executes the corresponding command:

```bash
$ gecho
gecko
```

In this case, the gnarly alias didn't save much typing at the command line, but
it is possible to alias more complex bash scripts as well:

```yaml
commands:
  gecho: echo "gecko"
  sysinfo:
    script: |
      echo "=== System Information ==="
      uname -a
      echo -e "\n=== CPU Info ==="
      lscpu | grep -E "^(Model name|Architecture|CPU\(s\))"
      echo -e "\n=== Memory Info ==="
      free -h
      echo -e "\n=== Disk Usage ==="
      df -h
      echo -e "\n=== Distribution Info ==="
      cat /etc/os-release | grep -E "^(NAME|VERSION)="
```

Now the named script 'sysinfo' can be executed with a simple command:

```bash
$ sysinfo
=== System Information ===
Linux VENGEANCE 5.15.167.4-microsoft-standard-WSL2 #1 SMP Tue Nov 5 00:21:55 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux

=== CPU Info ===
Architecture:                         x86_64
CPU(s):                               32
Model name:                           Intel(R) Core(TM) i9-14900KF

[... Etc. ...]
```

## Config File Search Path

As described in the Overview, the commands exutable by `gnarly` are defined in
a `.gnarly.yml` file.

`gnarly` first looks for this `.gnarly.yml` file in the current working
directory. If it exists, then the command to be executed is looked up in this
file. Otherwise, `gnarly` iterates through all parent directories of the
current working directory looking for a `.gnarly.yml` file until one is found.
If no file is found, then a "command not found" error message is echoed, and
`gnarly` exits.

For example, say you have created a `gnarly` config file at this location:

`/projects/myproj/.gnarly.yml`

In that case, you can execute `gnarly` commands from this config file in any
child directory of `/projects/myproj`, such as `/projects/myproj/src/app/profile`.

In this way, the commands configured in your `.gnarly.yml` file can be
tailored to this particular project and activated only when you are in this
directory or any subdirectory. Contrast this with bash aliases, which apply
regardless of which directory you are in.

As a result, `gnarly` is very useful as a way of managing several commands or
small scripts that are frequently used in a project. The `gnarly` config file
can be checked into version control and shared with other team members as well.

## Initialize a Directory for Use With Gnarly

To initialize the current working directory with a `.gnarly.yml` file,
issue the following command:

```bash
$ gnarly init
Creating .gnarly.yml
```

This will create the `.gnarly.yml` file that is initialized with a single
`gecho` command that you can use to quickly test (and then replace with your
own commands).

The created `.gnarly.yml` file includes a helpful comment at the top that shows
the supported command definition formats.

## Environment Variables

### Static Settings

These environment variables are static settings that can be overridden from outside of `gnarly.sh` if desired.

| Name                 | Description                                                                                   | Default Value |
| -------------------- | --------------------------------------------------------------------------------------------- | ------------- |
| `GNARLY_DEBUG`       | Enables gnarly debug logging (`0` = off; any other value = on)                                | `0`           |
| `GNARLY_FILENAME`    | Name of the gnarly config file                                                                | `.gnarly.yml` |
| `GNARLY_PATH`        | A colon (:) separated list of allowed gnarly config file search paths                         | `$HOME`       |

### "Source" Settings

These environment variables are set at the time `gnarly.sh` is sourced. Their values are determined automatically and
are not designed to be overridden outside of `gnarly.sh`.

| Name                 | Description                                                                                   | Default Value                                  |
| -------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `GNARLY_HOME`        | Full path to the gnarly installation directory; determined at the time `gnarly.sh` is sourced | `$(dirname "$(realpath "${BASH_SOURCE[0]}")")` |

### Dynamic Settings

These environment variables are set when gnarly finds and activates a `.gnarly.yml` file. They can be useful to
reference within command definitions inside of a `.gnarly.yml` file.

| Name                 | Description                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------- |
| `GNARLY_CFG_DIR`     | Full path to the directory that holds the in-effect gnarly config file                      |
| `GNARLY_CFG_FILE`    | Full path to the gnarly config file in effect                                               |
