#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un domaine"
USAGE="(-d|--domain) domain_name [options]"
OPTIONS=""


PARAMS=`getopt -o d:,h,v -l domain:,help,version -- "$@" `
[ $? != 0 ]
eval set -- "$PARAMS"

while true ; do
	case "$1" in
	-d|--domain) opt_domain="1" ; shift 1
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
#if no domain, then exit
[ -z "$opt_domain" ] && error "Domain name is missing"

#argument vs system ckeckings :
[ -z "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domail_val is unknown"
[ -n "`lsof $DOMAIN_POOL_ROOT/$opt_domain_val`" ] && error "Domain $opt_domail_val cannot be unmounted" 
# && echo "processes : `lsof -t $DOMAIN_POOL_ROOT/$opt_domain_val`" #umount check



opt_password_val=`query "select password from domains where name='$opt_domain_val';"` && [ -n "$opt_password_val" ] && opt_name_val=`query "select client from domains where name='$opt_domain_val';"` && [ -n "$opt_name_val" ] && opt_size_val=`query "select size from domains where name='$opt_domain_val';"` && [ -n "$opt_size_val" ] && opt_domain_val=`query "select name from domains where name='$opt_domain_val';"` && [ -n "$opt_domain_val" ]  || error "Cannot fetch parameters for domain $opt_domain_val"

# a partir d'içi, il est possible de modifier le niveau du système !
sysupdate delete # on demande une suppression du domaine


error "plus rien a faire ici !!!"
