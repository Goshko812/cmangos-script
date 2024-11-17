#!/bin/bash

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

check_os() {
    if ! grep -q "Ubuntu 22.04" /etc/os-release; then
        echo "This script is intended for Ubuntu 22.04" 1>&2
        exit 1
    fi
}
