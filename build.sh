##!/bin/bash

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y git curl wget unzip zip nginx mysql-client

# Install PHP and required extensions
sudo apt-get install -y php-fpm php-cli php-mysql php-curl php-gd php-imagick php-intl php-mbstring php-xml php-zip
sudo apt-get install php7.4-fpm
sudo systemctl start php7.4-fpm.service

# Install PHP dependencies
sudo composer install --no-dev

# Install or enable PHP's bcmath extension
sudo apt-get install -y php8.1-bcmath

# Update moneyphp/money package to the latest version
composer update moneyphp/money

# Install Composer
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Clone Akaunting repository
cd /var/www/
sudo git clone https://github.com/processmedic/akaunting.git
cd akaunting

# Update omnipay/common package to the latest version
composer update omnipay/common

# Create the .env file
sudo cp .env.example .env

# Generate the application key
sudo php artisan key:generate

# Set database information
sudo sed -i 's/DB_DATABASE=homestead/DB_DATABASE=akaunting/g' .env
sudo sed -i 's/DB_USERNAME=homestead/DB_USERNAME=root/g' .env
sudo sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=fivepines/g' .env

# Install and build frontend assets
sudo npm install
sudo npm run dev

# Configure Nginx
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-available/akaunting
sudo ln -s /etc/nginx/sites-available/akaunting /etc/nginx/sites-enabled/
sudo sed -i 's|root /var/www/html|root /var/www/akaunting/public|' /etc/nginx/sites-available/akaunting
sudo sed -i 's|listen 80 default_server|listen 80;|' /etc/nginx/sites-available/akaunting
sudo sed -i 's|server_name _;|server_name 192.168.0.22;|' /etc/nginx/sites-available/akaunting

# Restart Nginx
sudo service nginx restart

# Set file and folder permissions
sudo chown -R www-data:www-data /var/www/akaunting
sudo chmod -R 775 /var/www/akaunting/storage
sudo chmod -R 775 /var/www/akaunting/bootstrap/cache

# Migrate database
sudo php artisan migrate --seed

# Restart PHP-FPM
sudo service php7.4-fpm restart

echo "Akaunting has been deployed successfully at http://192.168.0.22"
notify-send "Installation Complete" "Akaunting has been installed!"