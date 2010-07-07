#--BEGIN
#dummy (pas de sauvegarde a virer)
query "insert into subdomains (name,domain,password) values ('$opt_subdomain_val','$opt_domain_val','$opt_password_val');"
useradd -g $opt_domain_val -d $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val -m -s /bin/false "$opt_subdomain_val.$opt_domain_val"
echo "$opt_subdomain_val.$opt_domain_val:$opt_password_val"|chpasswd
rm -f $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val/.bas* $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val/.profile 
chown $opt_subdomain_val.$opt_domain_val:$opt_domain_val $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val
chmod 755 $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val
( [ ! -f "/tmp/$opt_subdomain_val.$opt_domain_val.tar" ] || ( pushd $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val && tar xpf /tmp/$opt_subdomain_val.$opt_domain_val.tar && popd ) )
( rm /tmp/$opt_subdomain_val.$opt_domain_val.tar || true )
placelock $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val
#dummy (pas d'enregistrement bdd a creer a ce niveau)
#--END
#--END
rm /tmp/$opt_subdomain_val.$opt_domain_val.tar ; true
#dummy (pas d'enregistrement bdd a supprimer a ce niveau)
userdel -r "$opt_subdomain_val.$opt_domain_val"
#dummy (pas de mise a 0 du mdp)
#dummy (pas de fichiers .bashrc et autre a ajouter)
#dummy (pas la peine de defaire les user/group)
#dummy (pas la peine de defaire les droits)
( pushd $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val && tar --create --file=/tmp/$opt_subdomain_val.$opt_domain_val.tar . && popd )
#dummy (pas d'archive a creer)
removelock $DOMAIN_POOL_ROOT/$opt_domain_val/$opt_subdomain_val
query "delete from subdomains where name='$opt_subdomain_val' and domain='$opt_domain_val';"
#--BEGIN
