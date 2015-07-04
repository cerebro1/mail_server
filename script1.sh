######################################script to setup mail server in single click#######################################################
# 1.Installing mysql for database

apt-get install -y mysql-server
read -p "Enter domain" dom
read -p "Enter password for mailuser" mailpwd
echo "CREATE DATABASE mailserver;"|mysql -u root --password=root
echo "CREATE TABLE virtual_domains (id int(11) NOT NULL auto_increment,name varchar(50) NOT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"|mysql -u root --password=root mailserver
echo "CREATE TABLE virtual_users (id int(11) NOT NULL auto_increment,password varchar(32) NOT NULL,email varchar(100) NOT NULL,question varchar(250),answer varchar(50) NOT NULL,PRIMARY KEY (id),UNIQUE KEY email (email)) ENGINE=InnoDB DEFAULT CHARSET=utf8;"|mysql -u root --password=root mailserver;
echo "GRANT SELECT ON mailserver.* TO 'mailuser' IDENTIFIED BY 'kiet';"|mysql -u root --password=root

# 2.Setting up SMTP (POSTFIX configuration)

echo y|apt-get install postfix postfix-mysql
echo "user = mailuser
password = kiet
hosts = 127.0.0.1
dbname = mailserver
query = SELECT 1 FROM virtual_domains WHERE name='%s'">/etc/postfix/virtual-mailbox-domains.cf
echo "user = mailuser
password = kiet
hosts = 127.0.0.1
dbname = mailserver
query = SELECT 1 FROM virtual_users WHERE email='%s'">/etc/postfix/mysql-virtual-mailbox-maps.cf
postconf -e virtual_mailbox_domains=mysql:/etc/postfix/virtual-mailbox-domains.cf
postconf -e virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/vmail -m
chown -R vmail:vmail /var/vmail
chmod u+w /var/vmail

# 3.Setting up IMAP (DOVECOT configuration)
echo y|apt-get install dovecot-pop3d dovecot-imapd dovecot-sieve dovecot-mysql
echo "!include_try /usr/share/dovecot/protocols.d/*.protocol
dict {
}
!include_try local.conf
protocols = imap 
disable_plaintext_auth = no
mail_location = maildir:/var/vmail/%d/%n/Maildir
namespace {
    type = private
    separator = .
    inbox = yes
}
auth_mechanisms = plain
userdb {
    driver = static
    args = uid=5000 gid=5000 home=/var/vmail/%d/%n
}
protocol lda {
    postmaster_address = postmaster@`$dom`
    mail_plugins = $mail_plugins sieve
}
service auth {
 unix_listener auth-userdb {
 }
 unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
service director {
  unix_listener login/director {
  }
  fifo_listener login/proxy-notify {
  }
  unix_listener director-userdb {
  }
  inet_listener {
  }
}
service imap-login {
}
service pop3-login {
}
protocol lmtp {
}
plugin {
}
service auth-worker {
}
service dict {
  unix_listener dict {
  }
}
service imap-login {
  inet_listener imap {
  }
  inet_listener imaps {
  }
}

service pop3-login {
  inet_listener pop3 {
  }
  inet_listener pop3s {
  }
}
service lmtp {
  unix_listener lmtp {
  }
}

service imap {
}

service pop3 {
}
plugin {
  sieve = ~/.dovecot.sieve
  sieve_dir = ~/sieve
}
ssl_cert = </etc/dovecot/dovecot.pem
ssl_key = </etc/dovecot/private/dovecot.pem">/etc/dovecot/dovecot.conf
echo "driver = mysql
connect = host=127.0.0.1 dbname=mailserver user=mailuser password=kiet
default_pass_scheme = PLAIN-MD5
password_query = SELECT email as user, password FROM virtual_users WHERE email='%u';">/etc/dovecot/dovecot-sql.conf.ext
chgrp vmail /etc/dovecot/dovecot.conf
chmod g+r /etc/dovecot/dovecot.conf
chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext
echo 'dovecot unix - n n - - pipe
  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f ${sender} -d ${recipient}' >> /etc/postfix/master.cf
postconf -e virtual_transport=dovecot
service dovecot restart #restarting dovecot
service postfix restart #restarting postfix

#4.Setting up web based IMAP email client(Roundcube configuration)

echo y|apt-get install roundcube roundcube-plugins
echo "Include /etc/roundcube/apache.conf" >> /etc/apache2/apache2.conf
echo "Alias /roundcube/program/js/tiny_mce/ /usr/share/tinymce/www/
Alias /roundcube /var/lib/roundcube" >> /etc/roundcube/apache.conf
sed -i 's/.*default_host.*/$rcmail_config['\''default_host'\''] = '\''127.0.0.1'\'';/' /etc/roundcube/main.inc.php
sed -i 's/.*smtp_server.*/$rcmail_config['\''smtp_server'\''] = '\''127.0.0.1'\'';/' /etc/roundcube/main.inc.php
service apache2 restart #apache http server restart
./script2
service apache2 restart
