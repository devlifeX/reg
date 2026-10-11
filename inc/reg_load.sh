# Old records remain readable; new records escape backslashes, semicolons and newlines.
reg_load () {
  local reg_record=$1 reg_command reg_encoded=0
  local -a reg_fields
  if [[ $reg_record == "$REG_RECORD_PREFIX"* ]]; then
    reg_record=${reg_record#"$REG_RECORD_PREFIX"}
    reg_encoded=1
  fi
  IFS=';' read -r -a reg_fields <<< "$reg_record"
  for reg_command in "${reg_fields[@]:1}"; do
    if [[ $reg_encoded == 1 ]]; then
      printf '%b\0' "$reg_command"
    else
      printf '%s\0' "$reg_command"
    fi
  done
}
