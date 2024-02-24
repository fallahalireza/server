#!/bin/bash
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

read -p "Enter domain name: " domain_name

laravel_directory="/var/www/sites/$domain_name"

if [ -d "$laravel_directory" ]; then
    echo "Error: Project directory '$laravel_directory' already exists!"
    exit 1
fi
# Create Laravel project
composer create-project --prefer-dist laravel/laravel "$laravel_directory"

# Change ownership of the Laravel directory to the web server user
chown -R www-data:www-data "$laravel_directory"

nginx_file="/etc/nginx/sites-available/$domain_name"

# Create Nginx configuration file
cat > "$nginx_file" <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name #domain_name;
    root #laravel_directory;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
# متغیر‌هایی که باید جایگزین شوند
declare -A variables
variables["#domain_name"]=$domain_name
variables["#laravel_directory"]="$laravel_directory/public"

# جایگزینی متغیرها
for key in "${!variables[@]}"; do
    sed -i "s|$key|${variables[$key]}|g" "$nginx_file"
done


# Create a symbolic link to enable the site
ln -s "/etc/nginx/sites-available/$domain_name" "/etc/nginx/sites-enabled/"

# Check Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx

echo "Laravel has been installed in $laravel_directory and the site is available at http://$domain_name"

