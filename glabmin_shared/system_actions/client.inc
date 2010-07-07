#--BEGIN
query "insert into clients (name,address,email) values('$opt_name_val','$opt_address_val','$opt_email_val')"
#--END
#--END
query "delete from clients where name='$opt_name_val';"
#--BEGIN
