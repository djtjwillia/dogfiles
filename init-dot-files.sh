#!/bin/sh
if [ $1 == "-p" ]
then 
    echo "\033[1;32mSetting up dot file resources\033[0m"
    DOT_FILES_TARGET_DIRECTORY=$HOME
elif [ $1 == "-t" ]
then
    echo " \033[1;32mTest dot files setup.\n"\
         "\033[0;32mTest files will be here:\033[3;93m  $HOME/test_dot_files\033[0m"
    DOT_FILES_TARGET_DIRECTORY=$HOME/test_dot_files
else
    DOT_FILES_TARGET_DIRECTORY=$HOME/should-not-be
    echo " \033[1;31mindex-dot-files usage:\n"\
         "\033[0;31mOne of the following is required as an aguement:\n"\
         "     -p:  Deploys to users home (~) directory.\n"\
         "     -t:  Deploys to ~/test_dot_files for evaluation and testing.\n\033[0m"
    exit 1
fi
mkdir -p $DOT_FILES_TARGET_DIRECTORY
if [ $(grep -c "##setme##" $PWD/dotfiles/zshrc) > 0 ]
then
    sed -i "" "s|##setme##|$PWD|" $PWD/dotfiles/zshrc
fi

if [ ! -d $PWD/archive ]
then
    mkdir $PWD/archive
fi
ARCHIVE=$PWD/archive

for f in $PWD/dotfiles/*
do
    BASE_FILE_NAME=$(basename $f)
    CURRENT_FILE_LOCATION=$DOT_FILES_TARGET_DIRECTORY/.$BASE_FILE_NAME

    if [ -a $DOT_FILES_TARGET_DIRECTORY/.$BASE_FILE_NAME ]
    then
        bufn=$(basename $CURRENT_FILE_LOCATION)_$(date "+%Y%m%d-%H%M%S")
        echo "\033[0;36m Found:          \033[0m$CURRENT_FILE_LOCATION\n"\
             "\033[0;36mBacking up to:  \033[0m$ARCHIVE/$bufn\n"

        mv  $CURRENT_FILE_LOCATION $ARCHIVE/$bufn
    fi
    ln -s $f $DOT_FILES_TARGET_DIRECTORY/.$BASE_FILE_NAME
done

