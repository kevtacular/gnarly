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
$ nodever
nodever: command not found
```

With gnarly, we can define this command in a `.gnarly/bash.yml` file like so:

```yaml
commands:
  nodever: node --version
```

Now, when the bash shell can't find a `nodever` executable, it calls the gnarly
hook (a function named `command_not_found_handle()`), which finds this command
in the `bash.yml` file and executes the corresponding command:

```bash
$ nodever
v18.16.0
```

In this case, the gnarly alias didn't save much typing at the command line, but
it is possible to alias more complex bash scripts as well:

```yaml
commands:
  nodever: node --version
  npminfo: |
    echo "version: $(npm --version)"
    echo "configuration:"
    npm config list
```

Now this set of commands can be executed with a simple command:

```bash
$ npminfo
version: 9.5.1
configuration:
; node bin location = /home/s3pedx/.nvm/versions/node/v18.16.0/bin/node
; node version = v18.16.0
; npm local prefix = /home/s3pedx/dev/sandbox/gnarly/test/.gnarly
; npm version = 9.5.1
; cwd = /home/s3pedx/dev/sandbox/gnarly/test/.gnarly
; HOME = /home/s3pedx
; Run `npm config ls -l` to show all defaults.
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
