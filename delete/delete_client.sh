#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="supprimer un client"
USAGE="(-n|--name) nom_du_client [options]"
OPTIONS=""

PARAMS=`getopt -o n:,h,v -l name:,help,version -- "$@"`
[ $? != 0 ]
eval set -- "$PARAMS"



while true ; do
	case "$1" in
	-n|--name) opt_name="1"	; shift 1
		[ -n "$1" ] && opt_name_val=$1 && shift 1 ;;
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
[ -z "$opt_name" ] && error "Client name is missing"

#argument vs system ckeckings :
[ -z "`query "select name from clients where name='$opt_name_val';"`" ] && error "Client $opt_name_val is unknown"

#validation :
opt_address_val=`query "select address from clients where name='$opt_name_val';"` &&  [ -n "$opt_address_val" ] && opt_email_val=`query "select email from clients where name='$opt_name_val';"` && [ -n "$opt_email_val" ] && opt_name_val=`query "select name from clients where name='$opt_name_val';"`  && [ -n "$opt_name_val" ] || error "Cannot fetch parameters for client $opt_name_val"

#mise a niveau
sysupdate delete

#otherwise, something went wrong.
error "something unexpected appened"
