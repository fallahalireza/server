#!/bin/bash

# Ask the user for the directory name
read -p "Enter the directory name for Laravel installation: " dirname

# Check if the directory already exists
if [ -d "/var/www/$dirname" ]; then
    echo "Directory already exists!"
    exit 1
fi

# Change to the web root directory
cd /var/www || exit

# Install Laravel using Composer
composer create-project --prefer-dist laravel/laravel "$dirname"

# Change ownership of the Laravel directory to the web server user
chown -R www-data:www-data "/var/www/$dirname"

# Output success message
echo "Laravel has been successfully installed in /var/www/$dirname"
