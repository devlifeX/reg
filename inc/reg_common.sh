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
      if [[ $i = "$1$SEPRATOR_FOR_SAVE" ]]; then
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
      if [[ $i = "$1$SEPRATOR_FOR_SAVE" ]]; then
        echo $line;
        exit;
      fi
      break;
    done
  done < "$FILE_NAME"

  echo ""
}

reg_get_all_cmd () {
  FILE_CONTENT="";
  while IFS='' read -r line || [[ -n "$line" ]]; do
    sep=' ' read -ra ADDR <<< "$line"
    output="$output \\n $line";
  done < "$FILE_NAME"
  echo $output;
}

reg_set_number_cmd () {
  IFS=$SEPRATOR_FOR_SAVE read -r -a args <<< "$@";
  counter=1;
  for i in "${args[@]:1}"; do
  output="$output $RED\$$counter:$BF $i";
    counter=$[counter+1];
  done
  echo $output;
}

reg_reload () {
  exec bash;
  return;
}

