# Reg

Reg is a small Bash tool for persistent aliases and named command groups.
Each group runs in your current shell, in order, and stops when a step fails.

## Installation

From a downloaded or cloned checkout:

```bash
bash installer.sh
source "$HOME/.local/share/reg/reg.sh"
```

The installer uses the local checkout, requires no `sudo` or download, and
installs privately in `~/.local/share/reg`. It adds the source line to `.bashrc`
for future Bash sessions. Reinstallation preserves saved commands; a failed
installation restores the previous directory. On the first upgrade from the
original `/usr/local/bin/reg/reg-master` installation, its command file is copied
if present. The old directory is left intact.

To use a checkout directly, source its `reg.sh` using its full path.

## Command groups

Quote each step as a separate argument:

```bash
reg add pull "git pull origin master" "vagrant provision" "gulp build"
reg pull
reg list
reg list pull
reg list pull -num
reg remove pull
```

Names use letters, digits, underscores, dots and hyphens, and start with a letter,
digit or underscore. Built-in names (`add`, `remove`, `list`, `alias`, `env`,
`reload`, `man`) are reserved. Empty steps and duplicate names are rejected.
Failures return a nonzero status.

Step numbers start at 1. Skip selected steps with `-s`, or run only selected
steps with `-t`; execution always follows the group's original order:

```bash
reg pull -s "2,3"  # only git pull
reg pull -t "2,3"  # only provision and build
```

Commands are shell code: pipes, quotes, wildcards and semicolons work normally.
They are preserved during registration and evaluated only when the group runs.
Changes such as `cd` or `export` affect the current shell. Save only commands
you intend to execute.

## Shell aliases and environment variables

```bash
reg alias gc 'git commit -m'
reg alias -d gc
reg env GREETING 'hello world'
reg env -d GREETING
reg reload
```

Alias and environment changes update `.bashrc` and the current shell without
restarting it. Values are saved literally, including spaces and quotes. Variable
names follow Bash's identifier rules. `reg reload` sources `.bashrc` explicitly.

## Storage

Commands live in `storage/reg.cmd` beside `reg.sh`. New records use a version
marker and escape backslashes, semicolons and newlines so steps round-trip
without changing their text. Original records remain readable and removable;
the old Reg version cannot read new records. Text already altered by an old
registration cannot be recovered automatically.

File updates use a temporary file and rename, preserving the original if the
write fails. Run modifying commands and the installer one at a time; concurrent
writes are not supported.

## Tests

Tests require Python 3, Bash and standard Unix tools; no Python packages are
needed. They run commands and installations in temporary checkouts and homes.

```bash
python3 -m unittest discover -s tests -v
```

## License

Apache License 2.0. See [LICENSE](LICENSE).
