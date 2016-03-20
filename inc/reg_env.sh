reg_env () {

  if [[ $2 == "-d" ]] && [[ $3 ]]; then
   reg_env_remove $@;
   return;
 fi

 if [[ $2 ]] && [[ $3 ]]; then
   reg_env_add $@;
   return;
 fi

 echo "not found";
}

reg_env_add () {
  cmd="export $2=$3";
  echo $cmd >> ~/.bashrc;
  print "Save (%bs)$2(%bf) successfull. you can use 'echo \$$2' to see your variable" $GREEN;
  reg_reload;
}


reg_env_remove () {
  sed --in-place "/export $3=/d" ~/.bashrc;
  print "Remove (%bs)$3(%bf) successfull." $GREEN;
  reg_reload;
}

