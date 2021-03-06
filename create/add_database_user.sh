#!/bin/bash

#inclusions des procédures communes et de la configuration.
source $(dirname $0)/../glabmin.conf
source $SCRIPTSDIR/glabmin_shared/common.sh

#petite aide du script. Les options -h et -v sont systèmatiques ...
DESCRIPTION="ajouter un utilisateur de bases de données mysql"
USAGE="(-d|--domain) nom_du_domaine (-u|--user) nom_utilisateur [options]"
OPTIONS="(-p|--password) mot_de_passe // mot de passe de l'utilisateur (defaut mot de passe du domaine)
 (-e|--email) admin_email // email de l'administrateur (defaut : email de l'administrateur bdd de nom_du_domaine)"


PARAMS=`getopt -o d:,p:,u:,e:,h,v -l domain:,password:,user:,email:,help,version -- "$@"`
[ $? != 0 ]
eval set -- "$PARAMS"


while true ; do
	case "$1" in
	-d|--domain) opt_domain="1"	; shift 1
		[ -n "$1" ] && opt_domain_val=$1 && shift 1 ;;
        -u|--user) opt_user="1"	; shift 1
		[ -n "$1" ] && opt_user_val=$1 && shift 1 ;;
	-e|--email) opt_email="1"	; shift 1
		[ -n "$1" ] && opt_email_val=$1 && shift 1 ;;
	-p|--password) opt_password="1"	; shift 1
		[ -n "$1" ] && opt_password_val=$1 && shift 1 ;;
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
[ -z "`query "select domain from database_domains where domain='$opt_domain_val';"`" ] && error "Service database for domain $opt_domain_val is disabled"
[ -z "$opt_password" ] && opt_password_val=`query "select password from domains where name=(select domain from database_domains where domain='$opt_domain_val');"`
[ -z "$opt_email" ] && opt_email_val=`query "select email from clients where name=(select client from domains where name='$opt_domain_val');"`
[ -z `echo $opt_user_val|egrep '^[a-zA-Z]+([_]?[a-zA-Z0-9]+)$'` ] && error "Invalid user name $opt_user_val"
[ "`echo ${#opt_user_val}`" -gt "16"  ] && error "User name $opt_user_val too long"
[ -z `echo $opt_email_val|egrep '\w+([._-]\w)*@\w+([._-]\w)*\.\w{2,4}'` ] && error "Invalid admin email $opt_email_val"
[ -n "`query "select name from database_users where name='$opt_user_val'"`" ] && error "User $opt_user_val already defined"
[ -n "`mysql -N -u $DATABASE_ADMIN_USER -p $DATABASE_ADMIN_PASS -e "use mysql ; select User from user where User='$opt_user_val';"`" ] && error "User $opt_user_val is system-dedicated"
[ "`query "select count(*) from database_users where domain='$opt_domain_val';"`" -ge "`query "select nbuser from database_domains where domain='$opt_domain_val';"`" ] && error "cannot add another user for domain $opt_domain_val"

#registering new http service
query "insert into database_users (domain,name,password,email) values ('$opt_domain_val','$opt_user_val','$opt_password_val','$opt_email_val');"

#verif
opt_user_val=`query "select name from database_users where domain='$opt_domain_val' and name='$opt_user_val';"`
opt_password_val=`query "select password from database_users where domain='$opt_domain_val' and name='$opt_user_val';"`

#upgrading system level
mysql -N -u $DATABASE_ADMIN_USER -p $DATABASE_ADMIN_PASS -e "use mysql ; create user '$opt_user_val'@'localhost' identified by '$opt_password_val';" && exit 0


#otherwise, something went wrong.
error "something unexpected appened"
#peut etre effacer içi l'enregistrement en bdd ??

