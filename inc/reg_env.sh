reg_env () {
  [[ $# == 3 ]] || { reg_error 'Usage: reg env NAME VALUE | reg env -d NAME'; return 1; }
  if [[ $2 == -d ]]; then
    [[ $3 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || { reg_error "Invalid variable name: $3"; return 1; }
    reg_env_remove "$@"
  else
    [[ $2 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || { reg_error "Invalid variable name: $2"; return 1; }
    reg_env_add "$@"
  fi
}

reg_env_add () {
  [[ ! $(declare -p "$2" 2>/dev/null) =~ ^declare\ -[^[:space:]]*r ]] || {
    reg_error "Read-only variable: $2"
    return 1
  }
  reg_update_bashrc "export $2=" "$(printf 'export %s=%q' "$2" "$3")" || return 1
  export "$2=$3" || return 1
  reg_print "Variable (%bs)$2(%bf) saved." "$REG_GREEN"
}

reg_env_remove () {
  [[ ! $(declare -p "$3" 2>/dev/null) =~ ^declare\ -[^[:space:]]*r ]] || {
    reg_error "Read-only variable: $3"
    return 1
  }
  reg_update_bashrc "export $3=" || return 1
  unset -- "$3" || return 1
  reg_print "Variable (%bs)$3(%bf) removed." "$REG_GREEN"
}
