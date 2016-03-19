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