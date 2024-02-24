#!/bin/bash

print_style () {
    local message="$1"
    local color_code="$2"

    case "$color_code" in
        "info") COLOR="96m" ;;
        "success") COLOR="92m" ;;
        "warning") COLOR="93m" ;;
        "danger") COLOR="91m" ;;
        "blue") COLOR="94m" ;;
        "purple") COLOR="95m" ;;
        "gray") COLOR="37m" ;;
        *) COLOR="0m" ;; # Default color
    esac

    STARTCOLOR="\e[$COLOR"
    ENDCOLOR="\e[0m"

    printf "$STARTCOLOR%b$ENDCOLOR" "$message"
}
display_error() {
    print_style "Error: $1" "danger" >&2
    echo
    exit 1
}
display_warning() {
    print_style "$1" "warning"
    echo
}
display_success() {
    print_style "$1" "success"
    echo
}
display_gray() {
    print_style "$1" "gray"
}
display_info() {
    print_style "$1" "info"
    echo
}
add_repository_ondrej() {
    local repository="$1"
    if apt-cache policy | grep -q "$repository"; then
        display_success "The repository 'ppa:$repository' is already added."
    else
        echo | sudo add-apt-repository -y ppa:"$repository"
    fi
}
check_package() {
    local package_name="$1"
    if dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "installed"; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}
install_package() {
    local package_name="$1"
    if ! check_package "$package_name"; then
        display_info "Package $package_name is not installed (sudo apt install $package_name -y). Installing...\n"
        sudo apt install "$package_name" -y || display_error "Failed to install $package_name. Exiting..."
        display_success "$package_name has been installed successfully."
    else
        display_info "Package $package_name is already installed.\n"
    fi
}
install_packages() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        install_package "$package"
    done
}
install_composer() {
    if ! [ -x "$(command -v composer)" ]; then
        display_info "Composer is not installed. Installing...\n"
        curl -sS https://getcomposer.org/installer -o composer-setup.php
        sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
        rm composer-setup.php
        display_success "Composer has been installed successfully."
    else
        display_info "Composer is already installed.\n"
    fi
}

display_php_version() {
    version=$(php -v | head -n 1 | awk '{print $2}' | cut -d'-' -f1)
    print_style "PHP version: " "purple"
    print_style "$version\n" "gray"
}

# Function to display version of MySQL
display_mysql_version() {
    version=$(mysql --version | awk '{print $3}'  | cut -d'-' -f1)
    print_style "MySQL version: " "purple"
    print_style "$version\n" "gray"
}

# Function to display version of Nginx
display_nginx_version() {
    version=$(nginx -v 2>&1 | awk '{print $3}' | cut -d'/' -f2)
    print_style "Nginx version: " "purple"
    print_style "$version\n" "gray"
}

print_style "Automatically deploy the Laravel project to the Ubuntu server\n" "purple"

sudo apt update -y
add_repository_ondrej "ondrej/php"
add_repository_ondrej "ondrej/nginx"
required_packages=("curl" "git" "unzip" "zip")
install_packages "${required_packages[@]}"

display_info "Checking if PHP and required extensions are installed..."
required_packages_php=("php" "php-xml" "php-ctype" "php-curl" "php-dom" "php-fileinfo" "php-filter" "php-hash" "php-mbstring" "php-openssl" "php-pcre" "php-pdo" "php-session" "php-tokenizer" "php-cli" "php-zip" "php-json" "php-mysql" "php-fpm")
install_packages "${required_packages_php[@]}"
display_success "Installation and setup completed. (php)"

install_package "nginx"
install_package "mysql-server"
install_composer

display_php_version
display_mysql_version
display_nginx_version

