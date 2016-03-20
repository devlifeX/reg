containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}

reg_select_args () {
  #$2 is 0,2,5 skip parameters

  IFS=$COMMAND_SEPRATOR read -r -a args <<< "$2";

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

  echo ${output[@]};
} 


reg_select_args_with_seprator () {
  #$2 is 0,2,5 skip parameters

  IFS=$COMMAND_SEPRATOR read -r -a args <<< "$2";

  output=();
  index=("$@");

  start_index=0;
  counter=$start_index;

  for word in "${@:$start_index}"; do
     containsElement $counter "${args[@]}";
     contain=$?;

     if [[ $contain -eq 0  ]]; then
      if [[ "$1" == "-s" ]]; then
        output+=(${index[$counter]}$SEPRATOR_FOR_SAVE);
      fi
    fi

    if [[ $contain -eq 1  ]]; then
      if [[ "$1" == "-t" ]]; then
        output+=(${index[$counter]}$SEPRATOR_FOR_SAVE);
      fi
    fi

    counter=$[$counter +1];
  done
  temp="${output[@]}";
  echo ${temp:0:${#temp}-3};
} 

reg_command () {

  if [[ $1 == "add" ]]; then
    reg_save "$@";
    return;
  fi

  if [[ $1 == "remove" ]]; then
    reg_remove "$@"
    return;
  fi

  if [[ $1 == "man" ]]; then
    reg_man $1;
    return;
  fi

  if [[ $1 == "list" ]]; then
    reg_show_list "$@";
    return;
  fi

  if [[ $1 == "-h" ]]; then
    reg_man $1;
    return;
  fi

  if [[ $1 == "-v" ]]; then
    reg_version;
    return;
  fi

  reg_execute $1;
}