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

install_dependencies() {
    apt update
    apt install -y build-essential git-core autoconf make patch libmysql++-dev mysql-server libtool libssl-dev grep binutils zlib1g-dev libbz2-dev cmake libboost-all-dev
    apt install -y g++-12
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 --slave /usr/bin/g++ g++ /usr/bin/g++-12
}

create_directories() {
    mkdir -p ~/cmangos/build
    mkdir -p ~/cmangos/run/etc
    cd ~/cmangos || exit
}

clone_repositories() {
    git clone https://github.com/cmangos/mangos-classic.git mangos
    cd mangos || exit
    git clone https://github.com/cmangos/playerbots
    cd ..
    git clone https://github.com/cmangos/classic-db.git
}

build_project() {
    cd ~/cmangos/build || exit
    cmake ../mangos -DCMAKE_INSTALL_PREFIX=~/cmangos/run -DBUILD_EXTRACTORS=ON -DPCH=1 -DDEBUG=0 -DBUILD_PLAYERBOTS=ON -DBUILD_AHBOT=ON
    make -j$(nproc)
    make install
}

copy_configs() {
    cd ~/cmangos/run/etc || exit
    cp mangosd.conf.dist mangosd.conf
    cp realmd.conf.dist realmd.conf
    cp ~/cmangos/mangos/src/game/AuctionHouseBot/ahbot.conf.dist.in ahbot.conf
    cp anticheat.conf.dist anticheat.conf
    cp aiplayerbot.conf.dist aiplayerbot.conf
}

install_databases() {
    cd ~/cmangos/classic-db || exit
    yes 9 | head -n 1 | ./InstallFullDB.sh
    sed -i 's|CORE_PATH=.*|CORE_PATH="/root/cmangos/mangos"|' InstallFullDB.config
    sed -i 's|AHBOT=.*|AHBOT="YES"|' InstallFullDB.config
    sed -i 's|PLAYERBOTS_DB=.*|PLAYERBOTS_DB="YES"|' InstallFullDB.config
    sed -i 's|MYSQL_PASSWORD=.*|MYSQL_PASSWORD="mangos"|' InstallFullDB.config
    ./InstallFullDB.sh
}

change_realmlist_ip() {
    read -p "Do you want to change the realmlist IP? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter your public or LAN IP: " ip_address
        mysql -u root -p -e "USE classicrealmd; UPDATE realmlist SET address = '$ip_address' WHERE id = 1;"
    fi
}

setup_systemd_services() {
    echo "[Unit]
Description=Realmd Service

[Service]
ExecStart=/root/cmangos/run/bin/realmd
WorkingDirectory=/root/cmangos/run/bin
User  =root
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/realmd.service

    echo "[Unit]
Description=Mangosd Service

[Service]
ExecStart=/root/cmangos/run/bin/mangosd
WorkingDirectory=/root/cmangos/run/bin
User  =root
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mangosd.service

    sudo systemctl daemon-reload
}

main() {
    check_root
    check_os
    install_dependencies
    create_directories
    clone_repositories
    build_project
    copy_configs
    install_databases
    change_realmlist_ip
    setup_systemd_services

    clear
    echo "CMangos setup completed successfully!
    Please remember to change Console.Enable line in your mangosd.conf file after creating an account to ensure the systemd service works properly:
    This setting must be updated to 0 to disable the console for the service to function correctly. Until then, you can keep the console enabled for account creation.
    After Console.Enable is set to 0 you can do systemctl enable realmd and systemctl enable mangosd"
}

main "$@"
