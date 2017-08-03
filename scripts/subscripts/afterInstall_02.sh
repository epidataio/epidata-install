#!/bin/sh

# Create folders for users
mkdir -p /var/local/epidata
mkdir -p /var/local/epidata/tutorials
cp -r /home/ubuntu/epidata/ipython/home/* /var/local/epidata
chown -R ubuntu:ubuntu /var/local/epidata/

# Generate self signed SSL certificate
openssl genrsa -des3 -passout pass:x -out epidata_self_signed.pass.key 2048
openssl rsa -passin pass:x -in epidata_self_signed.pass.key -out /etc/ssl/certs/epidata_self_signed.key
rm epidata_self_signed.pass.key
openssl req -new -key /etc/ssl/certs/epidata_self_signed.key -out /etc/ssl/certs/epidata_self_signed.csr \
  -subj "/C=US/ST=California/L=RWC/O=EpiData/OU=DevOps/CN=app.epidata.io"
openssl x509 -req -days 365 -in /etc/ssl/certs/epidata_self_signed.csr -signkey /etc/ssl/certs/epidata_self_signed.key -out /etc/ssl/certs/epidata_self_signed.crt

# Update Server name
export SERVER_NAME=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
sed -i s/server_base_url/$SERVER_NAME/g /home/ubuntu/epidata-install/config/epidata
sed -i s/server_base_url/$SERVER_NAME/g /home/ubuntu/epidata/jupyter/config.py

# Copy configuration files to nginx folder
cp -f /home/ubuntu/epidata-install/config/nginx.conf /etc/nginx/
cp -f /home/ubuntu/epidata-install/config/epidata /etc/nginx/sites-available/

# Create symbolic link in sites-enabled folder
NGINX_EPIDATA='/etc/nginx/sites-enabled/epidata'
if [ -e $NGINX_EPIDATA ]; then
  echo "symbolic link $NGINX_EPIDATA already exists"
else
  echo "creating smybolic link $NGINX_EPIDATA"
  ln -s /etc/nginx/sites-available/epidata /etc/nginx/sites-enabled/epidata
fi

# Delete 'default' symbolic link in epidata-enabled
NGINX_DEFAULT='/etc/nginx/sites-enabled/default'
if [ -e $NGINX_DEFAULT ]; then
  echo "removing symbolic link $NGINX_DEFAULT"
  rm -f $NGINX_DEFAULT
else
  echo "symbolic link $NGINX_DEFAULT does not exist"
fi

# Test nginx configuration
nginx -t

# Restart nginx server
service nginx restart
service nginx status

echo "end of script"

# End of Script

