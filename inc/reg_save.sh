reg_save () {
  [[ $# -ge 3 ]] || { reg_error 'Usage: reg add NAME COMMAND [COMMAND ...]'; return 1; }
  reg_valid_name "$2" || return 1
  case $2 in
    add|remove|list|alias|env|reload|man) reg_error "Reserved name: $2"; return 1 ;;
  esac
  [[ -f $REG_FILE_NAME && -r $REG_FILE_NAME && -w $REG_FILE_NAME ]] || {
    reg_error "Cannot write $REG_FILE_NAME"
    return 1
  }
  if reg_get_cmd_by_name "$2" >/dev/null; then
    reg_error "Command already exists: $2"
    return 1
  fi
  local reg_record="$REG_RECORD_PREFIX$2" reg_command
  for reg_command in "${@:3}"; do
    [[ -n $reg_command ]] || { reg_error 'Commands must not be empty'; return 1; }
    reg_command=${reg_command//\\/\\\\}
    reg_command=${reg_command//;/\\073}
    reg_command=${reg_command//$'\n'/\\012}
    reg_record="$reg_record;$reg_command"
  done
  reg_update_file "$REG_FILE_NAME" "$REG_RECORD_PREFIX$2;" "$reg_record" || return 1
  reg_print "Command (%bs)$2(%bf) saved." "$REG_GREEN"
}
