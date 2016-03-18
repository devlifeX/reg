containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}

reg_select_args () {
  count_of_params=$#;
  # echo $count_of_params;
  #echo $#;
  #-s 0,1,2,5,6 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
  
  IFS=$COMMAND_SEPRATOR read -r -a args <<< "$2";
  # echo "${args[@]}";
  output=();
  index=("$@");

  start_index=0;
  counter=$start_index;

  for word in "${@:$start_index}"; do
     containsElement $counter "${args[@]}";
     contain=$?;

     if [[ $contain -eq 0  ]]; then
      if [[ "$1" == "-s" ]]; then
        output+=(${index[$counter]});
      fi
    fi

    if [[ $contain -eq 1  ]]; then
      if [[ "$1" == "-t" ]]; then
        output+=(${index[$counter]});
      fi
    fi

    counter=$[$counter +1];
  done

  echo "${output[@]}";
} 

reg_command () {

  if [[ $1 == "add" ]]; then
    reg_save "$@";
    return;
  fi

  if [[ $1 == "remove" ]]; then
    echo "remove";
    return;
  fi

  if [[ $1 == "man" ]]; then
    reg_man $1;
    return;
  fi

  if [[ $1 == "-h" ]]; then
    reg_man $1;
    return;
  fi


}