#!/bin/sh
# Tested on Ubuntu 14.04.4 LTS

sudo apt-get update

# Install other software
sudo apt-get install git -y zip -y


# Install NodeJS
cd ~
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs


# Install other dependancies 
sudo npm install pm2 -g
sudo npm install bower -g
sudo npm install -g grunt-cli
sudo apt-get install ruby -y
sudo su -c "gem install sass"


# Install nginx
sudo apt-get install nginx -y

sudo echo "server {" >> default;
sudo echo "    listen 80;" >> default;
sudo echo "    server_name localhost;" >> default;
sudo echo "    location / {" >> default;
sudo echo "        proxy_pass http://127.0.0.1:3000;" >> default;
sudo echo "        proxy_http_version 1.1;" >> default;
sudo echo "        proxy_set_header Upgrade \$http_upgrade;" >> default;
sudo echo "        proxy_set_header Connection 'upgrade';" >> default;
sudo echo "        proxy_set_header Host \$host;" >> default;
sudo echo "        proxy_cache_bypass \$http_upgrade;" >> default;
sudo echo "        proxy_set_header X-Real-IP \$remote_addr;" >> default;
sudo echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> default;
sudo echo "    }" >> default;
sudo echo "}" >> default;

sudo mv /etc/nginx/sites-available/default /etc/nginx/~default.bak
sudo mv default /etc/nginx/sites-available/default


# Install mongo db (this will change depending on the Ubuntu version)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
# Runs on port 27017
# Data is stored in /var/lib/mongodb
# Logs are stored in /var/log/mongodb
# Runs using the mongodb account
# Config is in /etc/mongod.conf

#Change bindIp: to 0.0.0.0 or a comma delimited list of ips to allow remote connection
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf


# Download and install API
sudo mkdir /var/www
cd /var/www
sudo git init
sudo git remote add origin https://github.com/mattgabriel/NodeJS-API.git
sudo git pull origin master
sudo npm install
sudo npm install apidoc -g
sudo apidoc -i ./ -o public/apiDocs/ -e node_modules

# Start servers
sudo service mongod restart 
sudo service nginx restart

# Start the API
pm2 stop www
NODE_ENV=stage pm2 start bin/www

echo "------------------------"
echo "------- ALL DONE -------"
echo "------------------------"








