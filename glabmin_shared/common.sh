#!/bin/bash

#methodes utilisées un peu partout dans les scripts ..
#source $(dirname $0)/../glabmin.conf

[ -z "$PARAMETERS" ] && PARAMETERS="\n"
[ -n "$OPTIONS" ] && OPTIONS=$OPTIONS"\n"


#place un vérrou dans un dossier passé en paramêtre (p. ex. /home/glabelle )
#Méthode sure, si le placement echoue, on nettoie et renvoie faux 
placelock () {
	( 
		[ -d "$@" ] &&
		touch $@/.lock &&
		chmod 000 $@/.lock &&
		chown root:root $@/.lock &&
		chattr +i $@/.lock #-> sortie si tout se passe bien
	) || ( 
		[ -e "$@/.lock" ] && 		#-> Sorties possibles quand cela se passe mal
		rm -fr  $@/.lock && false	#-> 
	)
}

#methode inverse, supprime un verrou .. 
removelock () {
	(
		[ -d "$@" ] &&
		chattr -i $@/.lock && 
		rm -fr $@/.lock
	) || (
		[ -e "$@/.lock" ] &&
		chattr +i $@/.lock && false
	)
}

sysupdate() {
	[ -z $1 ] && error "Parameter not set (must be either \"delete\" or \"create\")"
	[ "$1" != "delete" ] && [ "$1" != "create" ] && error "Parameter \"$1\" is not valid must be either \"delete\" or \"create\")" 
	[ "$1" = "create" ] && tmp=$(basename $0) && tmp=${tmp/create_/} && tmp=${tmp/.sh/} && message="CREATE"
	[ "$1" = "delete" ] && tmp=$(basename $0) && tmp=${tmp/delete_/} && tmp=${tmp/.sh/} && message="DELETE"
	let b=`cat $SCRIPTSDIR/glabmin_shared/system_actions/$tmp.inc|wc -l`/2
	echo "">>$LOGFILE_NAME
	echo "/--------------------- $message $tmp ----------------------">>$LOGFILE_NAME 
	while read line
	do
		let b=b-1
		( echo -e '\E[42m'"\033[1mCOMMIT\033[0m"": $line" && eval "$line" && echo "|  OK:`whoami`:`date +"%m-%d-%Y %T"`:$line">>$LOGFILE_NAME ) || ( echo "|->KO:`whoami`:`date +"%m-%d-%Y %T"`:$line">>$LOGFILE_NAME  && error "commit command failed, trying to rollback ..." ) || while read enil
		do
			(( $b >= 0 )) || ( echo -e '\E[43m'"\033[1mROLLBACK\033[0m"": $enil" && eval "$enil" && echo "|  OK:`whoami`:`date +"%m-%d-%Y %T"`:$enil">>$LOGFILE_NAME  ) || ( echo "| ERR:`whoami`:`date +"%m-%d-%Y %T"`:$enil">>$LOGFILE_NAME ; echo "\--------------------- $message $tmp KO , ROLLBACK KO ----------------------">>$LOGFILE_NAME ; false) || error "Rollback failed on \"$enil\""
			[ "$enil" = "#--END" ] && echo "\--------------------- $message $tmp KO , ROLLBACK OK ---------------">>$LOGFILE_NAME && exit 0
			let b=b-1
		done < <( [ "$1" = "delete" ] && cat "$SCRIPTSDIR/glabmin_shared/system_actions/$tmp.inc" || tac "$SCRIPTSDIR/glabmin_shared/system_actions/$tmp.inc" )
		[ "$line" = "#--END" ] && echo "\--------------------- $message $tmp OK ----------------------">>$LOGFILE_NAME && exit 0
	done < <( [ "$1" = "delete" ] && tac "$SCRIPTSDIR/glabmin_shared/system_actions/$tmp.inc" || cat "$SCRIPTSDIR/glabmin_shared/system_actions/$tmp.inc" )
}

error() {
	echo  -e '\E[41m'"\033[1mERROR\033[0m"": $@" ; exit 1
}

warning() {
	echo  -e '\E[43m'"\033[1mWARNING\033[0m"": $@" ; true
}

query() {
	mysql -N -h$DATABASE_HOST -u$DATABASE_USER -p$DATABASE_PASS -e"use $DATABASE_NAME ; $@"
}

backuptable() {
	mysqldump -h$DATABASE_HOST -u$DATABASE_ADMIN_USER -p$DATABASE_ADMIN_PASS $DATABASE_NAME $@	
}

restoretable() {
	mysql -N -h$DATABASE_HOST -u$DATABASE_ADMIN_USER -p$DATABASE_ADMIN_PASS -e"use $DATABASE_NAME ; $@"
}


usage(){
echo "$(basename $0), $DESCRIPTION

Usage:
------
 $(basename $0) $USAGE
 
Options:
-------------
 $OPTIONS(-h|--help) //Cet ecran d'aide
 (-v|--version) //Version du script

Parameters:
-------------
 $PARAMETERS"
}
