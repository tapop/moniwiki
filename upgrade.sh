#!/bin/sh
# $Id$

if [ -z "$1" ]; then
	cat <<HELP
Usage: $0 moniwiki-<ver>.tgz
HELP
	exit 0
fi

SUCCESS="echo -en \\033[1;32m"
FAILURE="echo -en \\033[1;31m"
WARNING="echo -en \\033[1;33m"
MESSAGE="echo -en \\033[1;34m"
NORMAL="echo -en \\033[0;39m"
MAGENTA="echo -en \\033[1;35m"

$SUCCESS
echo
echo "+-------------------------------+"
echo "|    MoniWiki upgrade script    |"
echo "+-------------------------------+"
echo "| This script compare all files |"
echo "|  between current and new.     |"
echo "|     All different files are   |"
echo "|  backuped in the backup       |"
echo "|  directory. And so you can    |"
echo "|  restore old one by manually. |"
echo "+-------------------------------+"
echo
$WARNING
echo -n " Press "
$MAGENTA
echo -n ENTER
$WARNING
echo -n " to continue or "
$MAGENTA
echo -n Control-C
$WARNING
echo -n " to exit "
$NORMAL
read

CHECKSUM=
PACKAGE=moniwiki

for arg; do

        case $# in
        0)
                break
                ;;
        esac

        option=$1
        shift

        case $option in
        -show|-s)
		show=1
                ;;
	*)
		TAR=$option
	esac
done

#
TMP=.tmp$$
$MESSAGE
echo "*** Extract tarball ***"
$NORMAL
mkdir -p $TMP
echo tar xzf $TAR -C$TMP
tar xzf $TAR -C$TMP
$MESSAGE
echo "*** Make the checksum list for the new version ***"
$NORMAL

FILELIST=$(find $TMP/$PACKAGE -type f | sed "s@^$TMP/$PACKAGE/@@")

rm -f checksum-new
(cd $TMP/$PACKAGE; for x in $FILELIST; do test -f $x && md5sum $x;done >> ../../checksum-new)

if [ ! -f "$CHECKSUM" ];then
	rm -rf checksum-current
	$MESSAGE
	echo "*** Make the checksum for current version ***"
	$NORMAL
	for x in $FILELIST; do test -f $x && md5sum $x;done >> checksum-current
	CHECKSUM=checksum-current
fi

UPGRADE=`diff checksum-current checksum-new |grep '^<'|cut -d' ' -f4`

if [ -z "$UPGRADE" ]; then
	$FAILURE
	echo "You have already installed the latest version"
	$NORMAL
	exit
fi
$MESSAGE
echo "*** Backup the old files ***"
$NORMAL

$WARNING
echo -n " What type of backup do you want to ? ("
$MAGENTA
echo -n B
$WARNING
echo -n "ackup/"
$MAGENTA
echo -n t
$WARNING
echo -n "ar/"
$MAGENTA
echo -n p
$WARNING
echo "atch) "
$NORMAL

echo "   (Type 'B/t/p')"
read TYPE

DATE=`date +%Y%m%d-%s`
if [ x$TYPE != xt ] && [ x$TYPE != xp ] ; then
        BACKUP=backup/$DATE
else
        BACKUP=$TMP/$PACKAGE-$DATE
fi
$MESSAGE
echo "*** Backup the old files ***"
$NORMAL
mkdir -p $BACKUP
tar cf - $UPGRADE|(cd $BACKUP;tar xvf -)

if [ x$TYPE = xt ]; then
	SAVED="backup/$DATE.tar.gz"
        (cd $TMP; tar czvf ../backup/$DATE.tar.gz $PACKAGE-$DATE)
        $MESSAGE
        echo "   Old files are backuped as a backup/$DATE.tar.gz"
        $NORMAL
elif [ x$TYPE = xp ]; then
	SAVED="backup/$PACKAGE-$DATE.diff"
        (cd $TMP; diff -ru moniwiki-$DATE $PACKAGE > ../backup/$PACKAGE-$DATE.diff )
        $MESSAGE
        echo "   Old files are backuped as a backup/$PACKAGE-$DATE.diff"
        $NORMAL
else
	SAVED="$BACKUP/ dir"
        $MESSAGE
        echo "   Old files are backuped to the $SAVED"
        $NORMAL
fi

$WARNING
echo " Are your really want to upgrade $PACKAGE ?"
$NORMAL
echo -n "   (Type '"
$MAGENTA
echo -n yes
$NORMAL
echo -n "' to upgrade or type others to exit)  "
read YES
if [ x$YES != xyes ]; then
	rm -r $TMP
	echo -n "Please type '"
	$MAGENTA
	echo -n yes
	$NORMAL
	echo "' to real upgrade"
	exit -1
fi
(cd $TMP/$PACKAGE;tar cf - $UPGRADE|(cd ../..;tar xvf -))
rm -r $TMP
$SUCCESS
echo
echo "$PACKAGE is successfully upgraded."
echo
echo
echo "   All different files are       "
echo "       backuped in the           "
echo "       $SAVED now. :)       "
$NORMAL
