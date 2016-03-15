reg_load () {
  FILE_CONTENT="";
  while IFS='' read -r line || [[ -n "$line" ]]; do
    FILE_CONTENT="$FILE_CONTENT$FILE_SEPRATOR$line"
  done < "$1"
  echo $FILE_CONTENT;
}

reg_is_command_exist () {
  FILE_CONTENT="";
  while IFS='' read -r line || [[ -n "$line" ]]; do
    sep=' ' read -ra ADDR <<< "$line"
    for i in "${ADDR[@]}"; do
      if [[ $i = $1 ]]; then
        echo "true";
        exit;
      fi
      break;
    done
  done < "$FILE_NAME"

  echo "false"
}