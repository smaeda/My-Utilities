#!/bin/sh
###################################################
##
## ctrl.sh
##
## 2008.02.08-
## smaeda
##
##################################################

## Usage : $ ctrl.sh "tar cvzf test.tgz test" backuptest

command=$1
locklabel=$2
MY_NAME=`basename $0`

#---------
# Settings
#---------
LOCK_FILE_DIR="/tmp"
LOCK_FILE="${LOCK_FILE_DIR}/${locklabel}.pid"
LOCK_SYMLINK="${LOCK_FILE}.lock"

#---------
# Pre
# 
#---------
# if $2 is "nolock", lockfile is not made.
if test "$locklabel" != "nolock" ;
then
    touch $LOCK_FILE || exit 1
    until ln -s $LOCK_FILE $LOCK_SYMLINK 2>/dev/null;
    do
        sleep 15
        trycnt=`expr ${trycnt:-0} + 1`
        test $trycnt -gt 20 && date "+%Y-%m-%d %T [$$] cannot start (locked)" > /dev/stderr && exit 1
    done
    echo -n $$ >$LOCK_FILE
    #trap
    trap "rm -f $LOCK_FILE $LOCK_SYMLINK" EXIT HUP INT QUIT TERM ABRT
fi

#--------
# Main
#--------
#start
date "+%Y-%m-%d %T [$$] started"

$command
#If exit code is returned, put stderr and exit 1
if test $? -ne 0 ;
then
    date "+%Y-%m-%d %T [$$] terminated" > /dev/stderr
    exit 1
fi

#finish
date "+%Y-%m-%d %T [$$] finished"

exit 0


