#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un sous-domaine"
USAGE="(-d|--domain) domain_name (-s|--subdomain) subdomain_name "
OPTIONS=""


PARAMS=`getopt -o d:,s:,h,v -l domain:,subdomain:,help,version -- "$@" `
[ $? != 0 ]
eval set -- "$PARAMS"

while true ; do
	case "$1" in
	-d|--domain) opt_domain="1" ; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
	-s|--subdomain) opt_subdomain="1" ;shift 1
		[ -n "$1" ] && opt_subdomain_val=$1 && shift 1 ;;	
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
[ -z "$opt_subdomain" ] && error "subdomain name is missing"

#argument vs system ckeckings :
[ -z "`query "select name from subdomains where name='$opt_subdomain_val' and domain='$opt_domain_val';"`" ] && error "Subdomain $opt_domail_val is unknown for domain $opt_domain_val"

#validation :
opt_password_val=`query "select password from subdomains where name='$opt_subdomain_val';"` && [ -n "$opt_password_val" ] && opt_subdomain_val=`query "select name from subdomains where name='$opt_subdomain_val';"` && [ -n "$opt_subdomain_val" ] && opt_domain_val=`query "select domain from subdomains where name='$opt_subdomain_val';"` && [ -n "$opt_domain_val" ]  || error "Cannot fetch parameters for subdomain $opt_subdomain_val"

#mise a niveau
sysupdate delete

#otherwise, something went wrong.
error "something unexpected appened"
