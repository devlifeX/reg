#!/bin/bash

. inc/reg_var.sh
. inc/reg_common.sh
. inc/reg_command_selector.sh
. inc/reg_man.sh
. inc/reg_load.sh
. inc/reg_save.sh
. inc/reg_remove.sh


reg () {
  reg_command "$@";

  exit;




  COUNTER=0;
  for word in "$@"; do
      if [[ $COUNTER -gt 0 ]]; then
        exe_args="$exe_args && $word";
        cmd_args="$cmd_args,  \033[1m \$$COUNTER='$word'\033[0m";
      else
        Function_name="$word";
      fi
    COUNTER=$[$COUNTER +1];
  done

  exe_args=${exe_args:3:${#exe_args}}
  #echo -e "$cmd_args";
  #echo  "$Function_name () { $exe_args }";
  #echo ${exe_args:3:${#exe_args}};

}

reg_execute () {
  is_exist=$(reg_is_command_exist $1);
  if [[ $is_exist = "false" ]]; then
    echo ""
    print "There is no command (%bs)$1(%bf)" $RED 
  fi
}



# reg -h
# reg "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg "push" "git psuh origin master"
# reg "log" "git log --oneline"
# reg "s" "git status" "git log -p"
reg add "down" "vagrant halt"
# reg remove "down"

# reg -s 0,1,2,5,6 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg -s 5,3 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
