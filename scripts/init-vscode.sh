#!/bin/sh

if [ $1 == "-s" ]
then 
    echo "\033[1;32mSetting up vscode resources\033[0m"
    cp ../vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
    cat extensions.list | xargs -L1 code --install-extension
elif [ $1 == "-t" ]
then
    echo " \033[1;32mTest vscode setup.\n"\
         "\033[0;32mTest settings.json will be here:\033[3;93m  $HOME/Library/Application\ Support/Code/User/settings.json\033[0m"
         "\033[0;32mReview extensions:\033[0m"
         cat extensions.list
else
    echo " \033[1;31mindex-dot-files usage:\n"\
         "\033[0;31mOne of the following is required as an aguement:\n"\
         "     -s:  Deploys to user;s vscode settings file, and installs all extensions in the list.\n"\
         "     -t:  Outputs where settings.json will go, and extensions list for evaluation and testing.\n\033[0m"
    exit 1
fi
