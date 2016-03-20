reg_alias () {
   if [[ $2 == "-d" ]] && [[ $3 ]]; then
   reg_alias_remove $@;
   return;
 fi

 if [[ $2 ]] && [[ $3 ]]; then
   reg_alias_add $@;
   return;
 fi

 echo "not found";
}

reg_alias_add () {
  cmd="alias $2=\"${@:3}\"";
  echo $cmd >> ~/.bashrc;
  print "Save (%bs)$2(%bf) successfull. you can use 'alias \$$2' to run your alias" $GREEN;
  reg_reload;
}

reg_alias_remove () {
  sed --in-place "/alias $3=/d" ~/.bashrc;
  print "Remove (%bs)$3(%bf) successfull." $GREEN;
  reg_reload;
}

