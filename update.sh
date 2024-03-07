#!/bin/bash

read -p "Enter domain name: " domain_name
laravel_directory="/var/www/sites/$domain_name"

if [ ! -d "$laravel_directory" ]; then
    echo "Error: Project directory '$laravel_directory' does not exist!"
    exit 1
fi

cd "$laravel_directory"

# Pull the latest changes from GitHub
git pull

# Install/update composer dependencies
composer install

# Change ownership of the Laravel directory to the web server user
chown -R www-data:www-data "$laravel_directory"

echo "The site has been updated successfully."
