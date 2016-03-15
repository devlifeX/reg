reg_man () {
  if [[ "$1" = "-h" ]]; then

    echo -e "\033[1m  \n NAME \033[0m";
    echo -e "\t reg - a Helper for alias shell command";

    echo -e "\033[1m  \n SYNOPSIS \033[0m";
    echo -e "\t reg [-h] [-s] <command>";

    echo -e "\033[1m  \n DESCRIPTION \033[0m";
    echo -e "\t Description";

    echo -e "\033[1m  \n OPTIONS \033[0m";
    echo -e "\t Options";

    exit;
  fi
}