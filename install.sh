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

print_style "Automatically deploy the Laravel project to the Ubuntu server\n" "purple"

display_info "Checking if PHP and required extensions are installed..."
# sudo apt update -y

# Check if PHP and required extensions are installed
required_packages=("php" "php-ctype" "php-curl" "php-dom" "php-fileinfo" "php-filter" "php-hash" "php-mbstring" "php-openssl" "php-pcre" "php-pdo" "php-session" "php-tokenizer" "php-xml" "php-cli" "php-zip" "php-json" "php-mysql")

for package in "${required_packages[@]}"; do
    if ! check_package "$package"; then
        display_info "Package $package is not installed. Installing...\n"
        display_info "sudo apt install $package -y\n"
        sudo apt install "$package" -y || display_error "Failed to install $package. Exiting..."
        display_success "$package has been installed successfully."
    else
        display_info "Package $package is already installed.\n"
    fi
done

display_success "Installation and setup completed. (PHP)"

