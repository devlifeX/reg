reg_load () {
  FILE_CONTENT="";
  while IFS='' read -r line || [[ -n "$line" ]]; do
    FILE_CONTENT="$FILE_CONTENT$FILE_SEPRATOR$line"
  done < "$1"
  echo $FILE_CONTENT;
}