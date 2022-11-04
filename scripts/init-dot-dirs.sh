#!/bin/sh
if [ $1 == "-p" ]
then 
    echo "\033[1;32mSetting up dot dir resources\033[0m"
    DOT_FILES_TARGET_DIRECTORY=$HOME
elif [ $1 == "-t" ]
then
    echo " \033[1;32mTest dot dirs setup.\n"\
         "\033[0;32mTest directories will be here:\033[3;93m  $HOME/test_dot_files\033[0m"
    DOT_FILES_TARGET_DIRECTORY=$HOME/test_dot_files
else
    DOT_FILES_TARGET_DIRECTORY=$HOME/should-not-be
    echo " \033[1;31mindex-dot-dirs usage:\n"\
         "\033[0;31mOne of the following is required as an aguement:\n"\
         "     -p:  Deploys to users home (~) directory.\n"\
         "     -t:  Deploys to ~/test_dot_files for evaluation and testing.\n\033[0m"
    exit 1
fi
mkdir -p $DOT_FILES_TARGET_DIRECTORY

if [ ! -d $PWD/archive ]
then
    mkdir $PWD/archive
fi
ARCHIVE=$PWD/archive

for d in $PWD/dotdirs/*
do
    BASE_DOT_DIR="."$(basename $d)
    mkdir -p $DOT_FILES_TARGET_DIRECTORY/$BASE_DOT_DIR
    CURRENT_FILE_LOCATION=$DOT_FILES_TARGET_DIRECTORY/$BASE_DOT_DIR
    for f in $d/*
    do 
        if [ -a $CURRENT_FILE_LOCATION/$(basename $f) ]
        then 
            bufn=$BASE_DOT_DIR--$(basename $f)_$(date "+%Y%m%d-%H%M%S")
            echo "\033[0;36m Found:          \033[0m$CURRENT_FILE_LOCATION/$(basename $f)\n"\
                "\033[0;36mBacking up to:  \033[0m$ARCHIVE/$bufn\n"
            mv $CURRENT_FILE_LOCATION/$(basename $f) $ARCHIVE/$bufn
        fi
        ln -s $f $CURRENT_FILE_LOCATION/$(basename $f)
    done
done
