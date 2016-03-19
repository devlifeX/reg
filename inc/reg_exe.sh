reg_execute () {

  is_exist=$(reg_is_command_exist $1);
  if [[ $is_exist = "false" ]]; then
    print "There is no command (%bs)$1(%bf)" $RED 
    exit;
  fi

cmd=$(reg_get_cmd_by_name $1);



  counter=0;
  for word in "$cmd"; do
    echo $word;
    counter=$[$counter +1];
  done


    # if [[ $counter -gt 0 ]]; then
    #   exe_args="$exe_args && $word";
    #   cmd_args="$cmd_args,  \033[1m \$$counter='$word'\033[0m";
    # else
    #   Function_name="$word";
    # fi
  # exe_args=${exe_args:3:${#exe_args}}
# echo exe_args;

  #echo -e "$cmd_args";
  #echo  "$Function_name () { $exe_args }";
  #echo ${exe_args:3:${#exe_args}};

}