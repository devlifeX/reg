reg_remove () {
  [[ $# == 2 ]] || { reg_error 'Usage: reg remove NAME'; return 1; }
  reg_valid_name "$2" || return 1
  local reg_record reg_prefix
  reg_record=$(reg_get_cmd_by_name "$2") || { reg_error "No such command: $2"; return 1; }
  reg_prefix="$2;"
  [[ $reg_record != "$REG_RECORD_PREFIX"* ]] || reg_prefix="$REG_RECORD_PREFIX$reg_prefix"
  reg_update_file "$REG_FILE_NAME" "$reg_prefix" || return 1
  reg_print "Command (%bs)$2(%bf) removed." "$REG_GREEN"
}
