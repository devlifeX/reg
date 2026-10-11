reg_alias () {
  [[ $# == 3 ]] || { reg_error 'Usage: reg alias NAME VALUE | reg alias -d NAME'; return 1; }
  if [[ $2 == -d ]]; then
    reg_valid_name "$3" || return 1
    reg_alias_remove "$@"
  else
    reg_valid_name "$2" || return 1
    reg_alias_add "$@"
  fi
}

reg_alias_add () {
  reg_update_bashrc "alias $2=" "$(printf 'alias %s=%q' "$2" "$3")" || return 1
  alias -- "$2=$3" || return 1
  reg_print "Alias (%bs)$2(%bf) saved." "$REG_GREEN"
}

reg_alias_remove () {
  reg_update_bashrc "alias $3=" || return 1
  unalias -- "$3" 2>/dev/null || :
  reg_print "Alias (%bs)$3(%bf) removed." "$REG_GREEN"
}
