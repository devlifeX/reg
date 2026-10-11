reg_man () {
  cat <<'HELP'
reg - Bash aliases and named command groups

Usage:
  reg add NAME COMMAND [COMMAND ...]
  reg remove NAME
  reg list [NAME [-num]]
  reg NAME [-s|-t INDEX[,INDEX...]]
  reg alias NAME VALUE | reg alias -d NAME
  reg env NAME VALUE   | reg env -d NAME
  reg reload
  reg -h | reg -v

-s skips steps; -t runs only selected steps. Indices start at 1.
Quote each command or value as a single argument.
HELP
}

reg_version () {
  printf 'Reg %s\nApache License 2.0\nhttps://github.com/devlifeX/reg\n' "$REG_VERSION"
}
