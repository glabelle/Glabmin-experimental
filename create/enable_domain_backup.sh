#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="ajouter un service de backup d'un domaine"
USAGE="(-d|--domain) nom_du_domaine [options]"
OPTIONS=""

PARAMS=`getopt -o d:,h,v -l domain:,help,version -- "$@"`
[ $? != 0 ]
eval set -- "$PARAMS"


while true ; do
	case "$1" in
	-d|--domain) opt_domain="1"	; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
	-h|--help) opt_help="1"	; shift 1 ;;
	-v|--version) opt_version="1"; shift 1 ;;
	--) shift ; break ;;
	esac
done

#command line checkings :
#if help wanted, display usage and exit
[ -n "$opt_help" ] && usage && exit 0
#if version, display version and exit 
[ -n "$opt_version" ] && echo "Version $(basename $0) $VERSION" && exit 0
#if no client or no email, then exit
[ -z "$opt_domain" ] && error "Domain name is missing"


#argument vs system ckeckings :
[ -z "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domail_val is unknown"
[ -n "`query "select name from domains where name='$opt_domain_val' and backup=1;"`" ] && error "Service backup for domain $opt_domain_val already present"

#registering new http service
query "insert into domains (backup) values (1);"

#verif
opt_domain_val=`query "select domain from http_domains where domain='$opt_domain_val'"`

#Mathieu : reprendre a partir d'içi..



#otherwise, something went wrong.
error "something unexpected appened"
#peut etre effacer içi l'enregistrement en bdd ??

