#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="ajouter un sous-domaine"
USAGE="(-d|--domain) domain_name (-s|subdomain) subdomain_name [options]"
OPTIONS="(-p|--password) mot_de_passe //par defaut subdomain.pass=domain.pass"

PARAMS=`getopt -o d:,s:,p:,h,v -l domain:,subdomain:,password:,help,version -- "$@" `
[ $? != 0 ]
eval set -- "$PARAMS"

while true ; do
	case "$1" in
	-d|--domain) opt_domain="1" ; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
	-s|--subdomain) opt_subdomain="1" ;shift 1
		[ -n "$1" ] && opt_subdomain_val=$1 && shift 1 ;;
	-p|--password) opt_password="1"	; shift 1
		[ -n "$1" ] && opt_password_val=$1 && shift 1 ;;
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
#if no domain, client or password, then exit
[ -z "$opt_subdomain" ] && error "Subdomain name is missing"
[ -z "$opt_domain" ] && error "Domain name is missing"


#argument vs system ckeckings :
[ -z "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domain_val is unknown"
[ -z `echo $opt_subdomain_val|egrep '^[a-zA-Z0-9]+([_-]?[a-zA-Z0-9]+)*$'` ] && error "Invalid subdomain name $opt_domain_val"
[ -n "`query "select name from restricted_names where name='$opt_subdomain_val';"`" ] && error "Subdomain name $opt_subdomain_val is restricted"
[ -n "`query "select name from subdomains where name='$opt_subdomain_val' and domain='$opt_domain_val';"`" ] && error "Subdomain $opt_subdomain_val already registered"
[ -e "$DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val" ] && error "A file or directory $opt_subdomain_val exists in domain $opt_domain_val"
[ -z "$opt_password" ] && opt_password_val=`query "select password from domains where name='$opt_domain_val';"`

#validation :
[ -n "$opt_password_val" ] && [ -n "$opt_subdomain_val" ] && [ -n "$opt_domain_val" ] || error "Some parameters of subdomain $opt_subdomain_val are not set"

#mise a niveau
sysupdate create

error "something unexpected appened"
