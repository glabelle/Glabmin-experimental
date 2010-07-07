#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="ajouter un domaine"
USAGE="(-n|--name) client_name (-d|--domain) domain_name (-p|--pasword) mot_de_passe [options]"
OPTIONS="(-s|--size) size_in_Mo //taille a allouer en megaoctets (defaut=$DOMAIN_DEFAULT_SIZE)"


PARAMS=`getopt -o n:,d:,s:,p:,h,v -l name:,domain:,size:,password:,help,version -- "$@" `
[ $? != 0 ]
eval set -- "$PARAMS"

while true ; do
	case "$1" in
	-d|--domain) opt_domain="1" ; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
	-n|--name) opt_name="1" ;shift 1
		[ -n "$1" ] && opt_name_val=$1 && shift 1 ;;
	-p|--password) opt_password="1"	; shift 1
		[ -n "$1" ] && opt_password_val=$1 && shift 1 ;;
	-s|--size) opt_size="1"	; shift 1
		[ -n "$1" ] && opt_size_val=$1 && shift 1 ;;
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
[ -z "$opt_name" ] && error "Client name is missing"
[ -z "$opt_domain" ] && error "Domain name is missing"
[ -z "$opt_password" ] && error "Password is missing"

#argument vs system ckeckings :
[ -z "`query "select name from clients where name='$opt_name_val';"`" ] && error "Client $opt_name_val is unknown"
[ -z `echo $opt_domain_val|egrep '^[a-zA-Z0-9]+([_-]?[a-zA-Z0-9]+)*([.]{1})[a-zA-Z0-9]+([.]?[a-zA-Z0-9]+)*$'` ] && error "Invalid domain name : $opt_domain_val"
[ -n "`query "select name from domains where name='$opt_domain_val';"`" ] && error "Domain $opt_domain_val already registered"
#if no size, using default size
[ -z "$opt_size" ] && opt_size_val=$DOMAIN_DEFAULT_SIZE
#checking if given size is ok
[ -z `echo $opt_size_val|egrep '^[1-9]+[[:digit:]]*$'` ] && error "Invalid domain size $opt_size_val"
[ -z `echo "$opt_size_val<=$DOMAIN_MAXIMUM_SIZE"|bc|egrep 1` ] && error "Domain size $opt_size_val too big (must be < $DOMAIN_MAXIMUM_SIZE)"


 
[ -n "$opt_password_val" ] && [ -n "$opt_name_val" ] && [ -n "$opt_size_val" ] && [ -n "$opt_domain_val" ] || error "Some parameters of domain $opt_domain_val are not set"

# a partir d'içi, il est possible de modifier le niveau du système !
sysupdate create # on demande une creation du domaine

error "something went wrong"
