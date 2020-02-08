#!/bin/bash
echo 'Start init'

if ! [ -f /.dockerinit ]; then
	touch /.dockerinit
	chmod 755 /.dockerinit
fi

if [ -z ${ROOT_PASSWORD} ]; then
	ROOT_PASSWORD=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 20)
	echo "Use generate password : ${ROOT_PASSWORD}"
fi

echo "root:${ROOT_PASSWORD}" | chpasswd

if [ ! -z ${APACHE_PORT} ]; then
	echo 'Change apache listen port to : '${APACHE_PORT}
	echo "Listen ${APACHE_PORT}" > /etc/apache2/ports.conf
	sed -i -E "s/\<VirtualHost \*:(.*)\>/VirtualHost \*:${APACHE_PORT}/" /etc/apache2/sites-enabled/000-default.conf
else
	echo "Listen 80" > /etc/apache2/ports.conf
	sed -i -E "s/\<VirtualHost \*:(.*)\>/VirtualHost \*:80/" /etc/apache2/sites-enabled/000-default.conf
fi

if [ ! -z ${MODE_HOST} ] && [ ${MODE_HOST} -eq 1 ]; then
	echo 'Update /etc/hosts for host mode'
	echo "127.0.0.1 localhost nextdom" > /etc/hosts
fi

if [ -f /usr/share/nextdom/core/config/common.config.php ]; then
	echo 'Nextdom is already install'
else
	echo 'Start Nexdom installation'
	rm -rf /root/install.sh
	wget https://raw.githubusercontent.com/NextDom/NextDom_Installer/master/NextDom_Installer_v1.9a.sh -O /root/install.sh
	chmod +x /root/install.sh
	/root/install.sh -s 6 -git

    # INSTALL XDEBUG
    apt install -y php-xdebug
    /etc/php/7.0/mods-available/xdebug.ini check with php -v | grep PHP

    # Enable Remote xdebug
    echo "xdebug.remote_enable = 1" >> /etc/php/7.0/mods-available/xdebug.ini
    echo "xdebug.remote_connect_back = 1" >> /etc/php/7.0/mods-available/xdebug.ini
    echo "xdebug.remote_port = 9900" >> /etc/php/7.0/mods-available/xdebug.ini
    echo "${VERT}étape 5.1 Activation Xdebug réussie${NORMAL}"
fi

echo 'All init complete'
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chown -R www-data:www-data /var/www/html

echo 'Start apache2'
systemctl restart apache2
service apache2 restart

echo 'Start atd'
systemctl restart atd
service atd restart