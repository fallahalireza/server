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

check_package() {
    local package_name="$1"
    if dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "installed"; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

install_packages() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if ! check_package "$package"; then
            display_info "Package $package is not installed. Installing...\n"
            display_info "sudo apt install $package -y\n"
            sudo apt install "$package" -y || display_error "Failed to install $package. Exiting..."
            display_success "$package has been installed successfully."
        else
            display_info "Package $package is already installed.\n"
        fi
    done
}

print_style "Automatically deploy the Laravel project to the Ubuntu server\n" "purple"

sudo apt update -y

display_info "Checking if PHP and required extensions are installed..."
required_packages=(
    "build-essential"
    "libbz2-dev"
    "libreadline-dev"
    "libsqlite3-dev"
    "libcurl4-gnutls-dev"
    "libzip-dev"
    "libssl-dev"
    "libxml2-dev"
    "libxslt-dev"
    "php8.1-cli"
    "php8.1-bz2"
    "php8.1-xml"
    "pkg-config"
)
install_packages "${required_packages[@]}"

curl -L -O https://github.com/phpbrew/phpbrew/releases/latest/download/phpbrew.phar
chmod +x phpbrew.phar
sudo mv phpbrew.phar /usr/local/bin/phpbrew
phpbrew init
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc
display_success "Installation and setup completed. (phpbrew)"
