#--BEGIN
#dummy (a priori, pas de sauvegarde a créer)
query "insert into domains (name,password,client,size) values ('$opt_domain_val','$opt_password_val','$opt_name_val',$opt_size_val);"
groupadd -f $opt_domain_val
useradd -g $opt_domain_val -d $DOMAIN_POOL_ROOT/$opt_domain_val -m -s /bin/false $opt_domain_val
echo $opt_domain_val:$opt_password_val|chpasswd
lvcreate -L $opt_size_val --name $opt_domain_val clients
mkfs.ext3 /dev/clients/$opt_domain_val
( [ ! -f "/tmp/$opt_domain_val.img" ] || dd if=/tmp/$opt_domain_val.img of=/dev/clients/$opt_domain_val ) #si une archive existe, on tente de la restaurer, sinon, erreur de rollback
( rm /tmp/$opt_domain_val.img || true ) #si une archive existe en tmp, on la vire .. echec impossible
mount /dev/clients/$opt_domain_val $DOMAIN_POOL_ROOT/$opt_domain_val
chown --preserve-root $opt_domain_val:$opt_domain_val $DOMAIN_POOL_ROOT/$opt_domain_val
chmod 750 $DOMAIN_POOL_ROOT/$opt_domain_val
( mv /etc/hosts /tmp/hosts.tmp && cat /tmp/hosts.tmp | while read line; do echo ${line/`hostname`/`hostname` $opt_domain_val} >> /etc/hosts; done && rm /tmp/hosts.tmp ) || ( mv /tmp/hosts.tmp /etc/hosts; rm /tmp/hosts.tmp; false )
#dummy (pas d'enregistrement bdd a creer a ce niveau)
#--END
#--END
rm /tmp/$opt_domain_val.img ; true #virer la sauvegarde
#dummy (pas d'enregistrement bdd a supprimer a ce niveau)
#dummy (A priori, le groupe est automatiquement viré)
userdel -r $opt_domain_val
#dummy (pas de mise a 0 du mot de passe $opt_password_val)
lvremove -f /dev/clients/$opt_domain_val
#dummy (pas de déformatage ext3 sur la partition virtuelle)
dd if=/dev/clients/$opt_domain_val of=/tmp/$opt_domain_val.img
#dummy (pas la peine de creer une sauvegarde)
umount /dev/clients/$opt_domain_val
#dummy (pas la peine de defaire les user/group)
#dummy (pas la peine de defaire les droits)
( mv /etc/hosts /tmp/hosts.tmp && cat /tmp/hosts.tmp | while read line; do echo ${line/$opt_domain_val /} >> /etc/hosts; done && rm /tmp/hosts.tmp ) || ( mv /tmp/hosts.tmp /etc/hosts; rm /tmp/hosts.tmp; false )
query "delete from domains where name='$opt_domain_val';"
#--BEGIN
