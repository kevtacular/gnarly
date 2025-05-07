# GNARLY - A Gnarlier Alias

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
$ hello
command not found: hello
```

With gnarly, we can define this command in a `.gnarly/bash.yml` file like so:

```yaml
commands:
  hello: echo "Hello, Gnarly!"
```

Now, when the bash shell can't find a `hello` executable, it calls the gnarly
hook (a function named `command_not_found_handle()`), which finds this command
in the `bash.yml` file and executes the corresponding command:

```bash
$ hello
Hello, Gnarly!
```

In this case, the gnarly alias didn't save much typing at the command line, but
it is possible to alias more complex bash scripts as well:

```yaml
commands:
  hello: echo "Hello, Gnarly!"
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
a `bash.yml` file located in a directory named `.gnarly`.

`gnarly` first looks for this `.gnarly` directory in the current working
directory. If it exists and contains a file named `bash.yml`, then the command
to be executed is looked up in this file. Otherwise, `gnarly` iterates through
all parent directories of the current working directory looking for a
`.gnarly/bash.yml` file until one is found. If no file is found, then a
"command not found" error message is echoed, and `gnarly` exits.

For example, say you have created a `gnarly` config file at this location:

`/projects/myproj/.gnarly/bash.yml`

In that case, you can execute `gnarly` commands from this config file in any
child directory of `/projects/myproj`, such as `/projects/myproj/src/app/profile`.

In this way, the commands configured in your `.gnarly/bash.yml` file can be
tailored to this particular project and activated only when you are in this
directory or any subdirectory. Contrast this with bash aliases, which apply
regardless of which directory you are in.

As a result, `gnarly` is very useful as a way of managing several commands or
small scripts that are frequently used in a project. The `gnarly` config file
can be checked into version control and shared with other team members as well.

## Initialize a Directory for Use With Gnarly

To initialize the current working directory with a `./gnarly/bash.yml` file,
issue the following command:

```bash
$ gnarly init
Creating .gnarly directory
Creating .gnarly/bash.yml
```

This will create the `.gnarly` directory with a `bash.yml` file that is
initialized with a single `hello` command that you can use to quickly test
(and then replace with your own commands).

The created `bash.yml` file includes a helpful comment at the top that shows
the supported command definition formats.

## Roadmap

Features planned for the future include:

- Search for multiple gnarly config files in the cwd hierarchy, with override
  capability
- Gnarly CLI features:
  - `gnarly exec [cmd]`
  - `gnarly add [name] [command|script] ...`
