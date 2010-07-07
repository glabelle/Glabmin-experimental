#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="demonter les bindings pour un domaine"
USAGE="(-d|--domain) nom_domaine [options]"
OPTIONS=""


PARAMS=`getopt -o d:,h,v -l domain:,help,version -- "$@" `
[ $? != 0 ]
eval set -- "$PARAMS"

while true ; do
	case "$1" in
	-d|--domain) opt_domain="1"	; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
	-h|--help) opt_help="1"	; shift 1 ;;
	-v|--version) opt_version="1"	; shift 1 ;;
	--) shift ; break ;;
	esac
done

#command line checkings :
#if help wanted, display usage and exit
[ -n "$opt_help" ] && usage && exit 0
#if version, display version and exit 
[ -n "$opt_version" ] && echo "Version $(basename $0) $VERSION" && exit 0
#if no domain or no password, then display help and exit
[ -z "$opt_domain" ] && echo "Domain name is missing"


#argument vs system ckeckings :
[ -n "`$DAEMON_DATABASE_SERVER status|grep 'MySQL is stopped'`" ] && echo "WARNING : trying start MySQL" && $DAEMON_DATABASE_SERVER start
[ -n "`$DAEMON_DATABASE_SERVER status|grep 'MySQL is stopped'`" ] && error "can't start MySQL"
[ -z "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domail_val is unknown"
[ -z "`mount|grep clients-$opt_domain_val`" ] && error "Domain $opt_domail_val is not mounted"


#démontages .. pas grand chose pour le moment ..

#1) On démonte les bdd :
if [ -n "`query "select domain from database_domains where domain='$opt_domain_val';"`" ] 
then
        opt_dbroot_val=`query "select dbroot from database_domains where domain='$opt_domain_val';"` &&
        base_list=`query "select name from database_bases where domain='$opt_domain_val';"` &&
        $DAEMON_DATABASE_SERVER stop
        echo $base_list
        for opt_base_val in $base_list
        do     
                echo "demontage de bdd $opt_base_val" &&
                umount $DB_SYSTEM_POOL/$opt_base_val/ &&
                echo "done"
        done
        $DAEMON_DATABASE_SERVER start
fi
#2) y'a t'il un pool de mail ? Si oui, on démonte sa racine
[ -n "`query "select domain from mail_domains where domain='$opt_domain_val';"`" ] && echo "demontage des mails $opt_domain_val" && umount $MAIL_SYSTEM_POOL/$opt_domain_val && echo "done"
#3) on démonte le domaine ..

echo "demontage de domaine $opt_domain_val" && umount /dev$DOMAIN_POOL_ROOT/$opt_domain_val && echo "done" && exit 0

#otherwise, something went wrong.
error "something unexpected appened"

