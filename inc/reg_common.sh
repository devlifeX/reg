print () {
  patterns=();
  patterns+=("\(%bs\)");
  patterns+=("\(%bf\)");

  replace=();
  replace+=($BS);
  replace+=($BF);

  message=$1;
  counter=0;
  for pattern in ${patterns[@]}; do
    close=${replace[$counter]}$2;
    message=${message//$pattern/$close};
   counter=$[$counter+1];
 done

 if [[ $2 ]]; then
  message="$2$message$BF";
fi

echo -e $message;
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

reg_get_cmd_by_name () {
  FILE_CONTENT="";
  while IFS='' read -r line || [[ -n "$line" ]]; do
    sep=' ' read -ra ADDR <<< "$line"
    for i in "${ADDR[@]}"; do
      if [[ $i = $1 ]]; then
        echo $line;
        exit;
      fi
      break;
    done
  done < "$FILE_NAME"

  echo ""
}