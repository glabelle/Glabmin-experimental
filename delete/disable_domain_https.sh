#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un service https"
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
[ -z "`query "select domain from https_domains where domain='$opt_domain_val';"`" ] && error "Service https for domain $opt_domain_val already disabled"

#verif
opt_domain_val=`query "select domain from https_domains where domain='$opt_domain_val'"`
opt_root_val=`query "select documentroot from https_domains where domain='$opt_domain_val'"`
opt_logs_val=`query "select logfiledir from https_domains where domain='$opt_domain_val'"`

#Deleting https service record
query "delete from https_domains where domain='$opt_domain_val'" &&
$DAMEON_HTTP_SERVER reload>/dev/null &&
removelock "$opt_root_val" &&
rm -fr $opt_root_val &&
removelock "$opt_logs_val" &&
rm -fr $opt_logs_val && exit 0


#otherwise, something went wrong.
error "something unexpected appened"
#peut etre effacer içi l'enregistrement en bdd ??















