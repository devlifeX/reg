reg_execute () {
  [[ $# == 1 || ( $# == 3 && ( $2 == -s || $2 == -t ) ) ]] || {
    reg_error 'Usage: reg NAME [-s|-t INDEX[,INDEX...]]'
    return 1
  }
  reg_valid_name "$1" || return 1
  local reg_record reg_command reg_index reg_number reg_selected
  local reg_mode=${2-} reg_selection=${3-} reg_count
  local -a reg_commands=() reg_indices=()
  reg_record=$(reg_get_cmd_by_name "$1") || { reg_error "No such command: $1"; return 1; }
  while IFS= read -r -d '' reg_command; do
    reg_commands+=("$reg_command")
  done < <(reg_load "$reg_record")
  reg_count=${#reg_commands[@]}
  [[ $reg_count -gt 0 ]] || { reg_error "Empty command group: $1"; return 1; }
  if [[ -n $reg_mode ]]; then
    [[ $reg_selection =~ ^[0-9]+(,[0-9]+)*$ ]] || { reg_error 'Invalid command indices'; return 1; }
    IFS=',' read -r -a reg_indices <<< "$reg_selection"
    for reg_number in "${!reg_indices[@]}"; do
      reg_index=${reg_indices[$reg_number]}
      # Normalize leading zeros without arithmetic overflow on untrusted input.
      while [[ ${#reg_index} -gt 1 && $reg_index == 0* ]]; do reg_index=${reg_index#0}; done
      [[ ${#reg_index} -le ${#reg_count} && $reg_index -ge 1 && $reg_index -le ${#reg_commands[@]} ]] || {
        reg_error "Command index out of range: $reg_index"
        return 1
      }
      reg_indices[$reg_number]=$reg_index
    done
  fi
  reg_number=0
  for reg_command in "${reg_commands[@]}"; do
    reg_number=$((reg_number + 1))
    reg_selected=0
    for reg_index in "${reg_indices[@]}"; do
      [[ $reg_index != "$reg_number" ]] || reg_selected=1
    done
    [[ $reg_mode != -s || $reg_selected == 0 ]] || continue
    [[ $reg_mode != -t || $reg_selected == 1 ]] || continue
    eval "$reg_command" || return $?
  done
  return 0
}

reg_show_list () {
  [[ $# == 1 || $# == 2 || ( $# == 3 && $3 == -num ) ]] || {
    reg_error 'Usage: reg list [NAME [-num]]'
    return 1
  }
  local reg_records reg_record reg_command reg_name reg_number
  if [[ $# == 1 ]]; then
    reg_records=$(cat -- "$REG_FILE_NAME") || return 1
  else
    reg_valid_name "$2" || return 1
    reg_records=$(reg_get_cmd_by_name "$2") || { reg_error "No such command: $2"; return 1; }
  fi
  while IFS= read -r reg_record || [[ -n $reg_record ]]; do
    [[ -n $reg_record ]] || continue
    reg_name=${reg_record#"$REG_RECORD_PREFIX"}
    [[ $# != 1 ]] || printf '%s' "${reg_name%%;*}"
    reg_number=0
    while IFS= read -r -d '' reg_command; do
      reg_number=$((reg_number + 1))
      if [[ $# == 1 ]]; then
        printf '; %s' "$reg_command"
      elif [[ ${3-} == -num ]]; then
        printf '%s: %s\n' "$reg_number" "$reg_command"
      else
        printf '%s\n' "$reg_command"
      fi
    done < <(reg_load "$reg_record")
    [[ $# != 1 ]] || printf '\n'
  done <<< "$reg_records"
}
