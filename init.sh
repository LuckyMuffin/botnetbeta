#!/bin/bash

public_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
global_server_name_full="$(grep ServerName /etc/apache2/apache2.conf)"
global_server_name_IP="$(grep ServerName /etc/apache2/apache2.conf | awk '{print $2}')"
uinput=""
redirect=/var/www/html/404.php
redirect_string="ErrorDocument 403 /404.php"
apache=/etc/apache2
apache_conf=/etc/apache2/apache2.conf

RED='\033[0;31m'
NC='\033[0m'

cat ./botpic
echo "Setting up CC at $public_ip"
echo "Stopping services..."
sleep .5
service apache2 stop
echo "Apache stopped"
sleep .5
service mysql stop
echo "MySql stopped"
sleep .5

echo "Checking for files..."
sleep .5
#404 redirect check.

if [[ ! -f $redirect ]]
then
    echo "404.php not found... Adding to /var/www/html/404.php"
    cp ./404.php /var/www/html/404.php
    echo "404.php installed" 
else
    echo "Found 404.php in ......... /var/www/html/404.php"
    sleep .5
fi

#apache2 check

if [[ ! -d $apache ]]
then
    echo "Apache2.conf not found... would you like to re-install apache? (yes / no)"
    read uinput
    if ["$uinput" == "yes"]; then
        apt-get purge apache2
        apt-get install apache2
        echo "Apache2 reinstalled"
    else
        echo "WARNING apache2.conf path not found, please change."
    fi
else
    echo "Apache2 already installed"
    sleep .5
fi

#apache2 check

if [[ ! -f $apache_conf ]]
then
    echo -e "${RED}***WARNING***${NC} apache.conf not found" 
else
    echo "Found Apache2.conf in .... /etc/apache2/apache2.conf"
    sleep .5
fi

#apache 2 redirect check

if grep -Fxq "$redirect_string" /etc/apache2/apache2.conf 
then
    echo "403 -> 404 redirection already enabled"
    sleep .5
else
    echo "403 -> 404 redirection not found..."
    echo "Adding 403 -> 404 redirect to apache2.conf"
    echo "ErrorDocument 403 /404.php" >> /etc/apache2/apache2.conf
    echo "Enabled 403 -> 404 redirection"
fi

#apache2 global ServerName check

echo "Looking for global servername..."
if grep -q "ServerName" /etc/apache2/apache2.conf
then
    echo "ServerName set to $global_server_name_full"
    sleep .5
else
    echo -e "${RED}***WARNING***${NC} ServerName not set. Setting ServerName to; $public_ip."
    echo "ServerName $public_ip" >> /etc/apache2/apache2.conf
fi

#PIP to GSN check
if [ "$public_ip" != "$global_server_name_IP" ]
then
    echo -e "${RED}***WARNING***${NC} ServerName not the same as public IP."
fi

#add to apache full firewall group.
echo "Adding webtraffic to apache full ruleset."
ufw allow in "Apache Full"

#php check

if ! [ -x "$(command -v php)" ]
then
    echo 'Error: PHP is not installed.' 
    echo "install with apt-get install php libapache2-mod-php php-mcrypt php-mysql"
else
    echo "PHP already installed"
    sleep .5
fi

#mysql check

if ! [ -x "$(command -v mysql)" ]
then
    echo 'Error: MySql is not installed.' 
    echo "Install with apt-get install mysql-server"
else
    echo "MySql already installed"
    sleep .5
fi

echo "Restarting apache..."
service apache2 start
echo "Apache up!"
echo "Restarting MySql..."
service mysql start
echo "MySql up!"
