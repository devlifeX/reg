Reg is simple tool for bash alias management

- [INSTALLATION](#installation)
- [DESCRIPTION](#description)
- [OPTIONS](#options)


# INSTALLATION
to install reg manually you can pull or download zip file and run installer.sh by this command

    bash installer.sh

# DESCRIPTION
**reg** is a small command-line bash program alias management. it requires the bash interpreter (almost unix os have it already).
you can use **reg** like this:

    reg add "pull" "git pull origin master" "vagrant provision" "gulp build"

for add alias you can use this command:

    reg add [alias name] [command 1] [command 2] [command n]

for remove alias:

    reg remove [alias name]

for show alias

    reg list [alias] [-num]

for call alias:

    reg [alias]
or
    reg [alias] [-s / -e] [command 1] [command 2] [command n]


**reg** has group alias, it means you can put many command as single alias name.

for example you can define this alias group

    reg add "pull" "git pull origin master" "vagrant provision" "gulp build"

and you can use like this:

    reg "pull"

or you can select specific command from alias group for example:

    reg "pull" -s "2,3"

it's mean you only run first command in this example it is 
    
    "git pull origin master"

you skiped command 2 and 3

this documentation will complete in future