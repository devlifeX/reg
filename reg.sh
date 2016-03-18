. reg_var.sh
. reg_command_selector.sh
. reg_man.sh
. reg_load.sh
. reg_save.sh


reg () {
  # reg_select_args "$@"; 
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

# reg -h
# reg "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg "push" "git psuh origin master"
# reg "log" "git log --oneline"
# reg "s" "git status" "git log -p"
reg add "down" "vagrant halt"

# reg -s 0,1,2,5,6 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
# reg -s 5,3 "pull" "git pull origin master" "vagrant provision" "gulp build" "gulp serve"
