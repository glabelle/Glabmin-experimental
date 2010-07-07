#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un repertoire a acces restreint du service http d'un domaine"
USAGE="(-d|--domain) nom_du_domaine  [options]"
OPTIONS="(-u|--directory) nom_du_dossier // depuis la racine http du domaine (par defaut ./)"

PARAMS=`getopt -o d:,r:,h,v -l domain:,directory:,help,version -- "$@"`
[ $? != 0 ]
eval set -- "$PARAMS"


while true ; do
	case "$1" in
	-d|--domain) opt_domain="1"	; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
        -r|--directory) opt_directory="1"	; shift 1
		[ -n "$1" ] && opt_directory_val=$1 && shift 1 ;;
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
[ -z "`query "select domain from http_domains where domain='$opt_domain_val';"`" ] && error "Service HTTP for domain $opt_domail_val is disabled"
[ -z "$opt_directory" ] && opt_directory_val=`query "select documentroot from http_domains where domain='$opt_domain_val';"`
[ -z "`query "select directory from http_domains_directorys where directory='$opt_directory_val'"`" ] && error "directory $opt_directory_val already removed"

#eventuellement à garder en option
#[ "`query "select count(*) from database_directorys where domain='$opt_domain_val';"`" -ge "`query "select nbdirectory from database_domains where domain='$opt_domain_val';"`" ] && error "cannot add another directory for domain $opt_domain_val"

#registering new http service
query "delete from http_domains_restricted where domain='$opt_domain_val' and directory='$opt_directory_val';"

#upgrading system level
$DAMEON_HTTP_SERVER reload>/dev/null && exit 0

#otherwise, something went wrong.
error "something unexpected appened"
#peut etre effacer içi l'enregistrement en bdd ??

