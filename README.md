# zimbra-zpush

Z-Push with Zimbra Backend. Compatible with Zimbra or Zextras Carbonio  
Details: https://imanudin.net/2023/10/07/exchange-activesync-for-zimbra-open-source-edition-nginx-custom/  

Tested with Ubuntu 22.04 and Zimbra 10.1.9.p1 (zcs-10.1.9_GA_4200001.UBUNTU22_64.20250721164603.tgz)  
```
apt install php-cli php-soap php-mbstring php-curl php-fpm php-intl git  
//change listen port to:
//listen = 127.0.0.1:9000
vim /etc/php/8.1/fpm/pool.d/www.conf
systemctl restart php8.1-fpm.service
mkdir /var/lib/z-push /var/log/z-push
chmod 755 /var/lib/z-push /var/log/z-push
chown www-data.www-data /var/lib/z-push /var/log/z-push
cd /opt/
git clone https://github.com/skalaradek/zimbra-zpush.git z-push
//adjust timezone
vim /opt/z-push/config.php
//Find line “location ^~ /Microsoft-Server-ActiveSync” and add below line before line “For audit”
//include /opt/z-push/nginx-zpush.conf;
vim /opt/zimbra/conf/nginx/templates/nginx.conf.web.https.default.template
// change define('ZIMBRA_URL', 'https://127.0.0.1'); to FQDN to get rid of warnings
vim /opt/z-push/backend/zimbra/config.php
su - zimbra -c 'zmproxyctl restart'
```
