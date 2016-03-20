reg_man () {
  if [[ "$1" = "-h" ]]; then

    print "(%bs)  \n NAME (%bf)"
    print "\t reg - a Helper for alias shell command"
    print "(%bs)  \n SYNOPSIS (%bf)"
    print "\t reg [-h] [-s] <command>"
    print "(%bs)  \n DESCRIPTION (%bf)"
    print "\t Description"
    print "(%bs)  \n OPTIONS (%bf)"
    print "\t Options"
  fi
  return;
}

reg_version () {
  print "\n";
  print "\t '(%bs)Reg(%bf)' version: $GREEN $REG_VERSION (%bf)";
  print "\t This version released under Apache License";
  print "\t Version 2.0, January 2004";
  print "\t Repo:";
  print "\t https://github.com/devlifeX/reg";
  print "\n";
}