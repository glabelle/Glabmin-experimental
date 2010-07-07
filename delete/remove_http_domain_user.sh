#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un utilisateur ayant un acces au service http restreint d'un domaine"
USAGE="(-d|--domain) nom_du_domaine (-u|--user) nom_utilisateur [options]"
OPTIONS=""

PARAMS=`getopt -o d:,p:,u:,e:,h,v -l domain:,password:,user:,email:,help,version -- "$@"`
[ $? != 0 ]
eval set -- "$PARAMS"


while true ; do
	case "$1" in
	-d|--domain) opt_domain="1"	; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
        -u|--user) opt_user="1"	; shift 1
		[ -n "$1" ] && opt_user_val=$1 && shift 1 ;;
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
[ -z "$opt_user" ] && error "User name is missing"

#argument vs system ckeckings :
[ -z "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domail_val is unknown"
[ -z "`query "select domain from http_domains where domain='$opt_domain_val';"`" ] && error "Service HTTP for domain $opt_domail_val is disabled"
[ -z "`query "select user from http_domains_users where user='$opt_user_val'"`" ] && error "User $opt_user_val already removed"

#eventuellement à garder en option
#[ "`query "select count(*) from database_users where domain='$opt_domain_val';"`" -ge "`query "select nbuser from database_domains where domain='$opt_domain_val';"`" ] && error "cannot add another user for domain $opt_domain_val"

#registering new http service
query "delete from http_domains_users where domain='$opt_domain_val' and user='$opt_user_val';"

#upgrading system level
$DAMEON_HTTP_SERVER reload>/dev/null && exit 0

#otherwise, something went wrong.
error "something unexpected appened"
#peut etre effacer içi l'enregistrement en bdd ??

