#!/bin/bash

check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "This script should not be run as root." 1>&2
        exit 1
    fi
}

install_dependencies() {
    echo "Select your operating system:"
    echo "1) Ubuntu 22.04"
    echo "2) Ubuntu 20.04"
    echo "3) Debian"
    echo "4) Arch Linux"
    read -p "Enter your choice (1-4): " os_choice

    case $os_choice in
        1)
            echo "Installing dependencies for Ubuntu 22.04..."
            sudo apt update
            sudo apt install -y build-essential git-core autoconf make patch libmysql++-dev mysql-server libtool libssl-dev grep binutils zlib1g-dev libbz2-dev cmake libboost-all-dev g++-12
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 --slave /usr/bin/g++ g++ /usr/bin/g++-12
            ;;
        2)
            echo "Installing dependencies for Ubuntu 20.04..."
            sudo apt update
            sudo apt install -y build-essential gcc g++ automake git-core autoconf make patch libmysql++-dev mysql-server libtool libssl-dev grep binutils zlibc libbz2-dev cmake libboost-all-dev
            ;;
        3)
            echo "Installing dependencies for Debian..."
            sudo apt update
            sudo apt install -y grep build-essential gcc g++ automake git-core autoconf make patch cmake libmariadb-dev libmariadb-dev-compat mariadb-server libtool libssl-dev binutils zlibc libc6 libbz2-dev subversion libboost-all-dev
            ;;
        4)
            echo "Installing dependencies for Arch Linux..."
            sudo pacman -Syu --noconfirm base-devel git cmake mariadb mariadb-libs boost boost-libs
            ;;
        *)
            echo "Invalid option. Please select a valid operating system."
            exit 1
            ;;
    esac
}

create_directories() {
    mkdir -p ~/cmangos/build
    mkdir -p ~/cmangos/run/etc
    cd ~/cmangos || exit
}

clone_repositories() {
    git clone https://github.com/cmangos/mangos-classic.git mangos
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
    sed -i 's|CORE_PATH=.*|CORE_PATH="$HOME/cmangos/mangos"|' InstallFullDB.config
    sed -i 's|AHBOT=.*|AHBOT="YES"|' InstallFullDB.config
    sed -i 's|PLAYERBOTS_DB=.*|PLAYERBOTS_DB="YES"|' InstallFullDB.config
    sed -i 's|MYSQL_PASSWORD=.*|MYSQL_PASSWORD="mangos"|' InstallFullDB.config
    sudo ./InstallFullDB.sh
}

change_realmlist_ip() {
    read -p "Do you want to change the realmlist IP? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter your public or LAN IP: " ip_address
        sudo mysql -u root -p -e "USE classicrealmd; UPDATE realmlist SET address = '$ip_address' WHERE id = 1;"
    fi
}

setup_systemd_services() {
    echo "[Unit]
Description=Realmd Service

[Service]
ExecStart=$HOME/cmangos/run/bin/realmd
WorkingDirectory=$HOME/cmangos/run/bin
User =$USER
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/realmd.service

    echo "[Unit]
Description=Mangosd Service

[Service]
ExecStart=$HOME/cmangos/run/bin/mangosd
WorkingDirectory=$HOME/cmangos/run/bin
User =$USER
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/mangosd.service

    sudo systemctl daemon-reload
}

extract_game_data() {
    read -p "Do you want to extract game data from ~/client/? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        if [ -d ~/client/ ]; then
            echo "Extracting game data from ~/client/..."
            echo "Copying extractor files to your WoW client directory..."
            cp ~/cmangos/run/bin/tools/* ~/client/

            echo "Setting executable permissions on extraction scripts..."
            chmod +x ~/client/ExtractResources.sh ~/client/MoveMapGen.sh

            echo "Ensure the Data directory starts with an uppercase D in your WoW client directory."
            echo "Running the data extraction..."
            cd ~/client || exit
            bash ./ExtractResources.sh

            echo "Extraction complete! Moving extracted folders to ~/cmangos/run/bin..."
            mv maps ~/cmangos/run/bin/
            mv dbc ~/cmangos/run/bin/
            mv vmaps ~/cmangos/run/bin/
            if [ -d "mmaps" ]; then
                mv mmaps ~/cmangos/run/bin/
            fi
            if [ -d "CreatureModels" ]; then
                mv CreatureModels ~/cmangos/run/bin/
            fi
            if [ -d "Cameras" ]; then
                mv Cameras ~/cmangos/run/bin/
            fi

            echo "If you didn't find the CreatureModels folder, don't worry, it's optional."
        else
            echo "Directory ~/client/ does not exist. Please ensure the game client is located there."
        fi
    else
        echo "Skipping game data extraction."
    fi
}

main() {
    check_root
    install_dependencies
    create_directories
    clone_repositories
    build_project
    copy_configs
    install_databases
    change_realmlist_ip
    setup_systemd_services
    extract_game_data

    echo "CMangos setup completed successfully!
    Please remember to change Console.Enable line in your mangosd.conf file after creating an account to ensure the systemd service works properly:
    This setting must be updated to 0 to disable the console for the service to function correctly. Until then, you can keep the console enabled for account creation.
    After Console.Enable is set to 0 you can do systemctl enable realmd and systemctl enable mangosd"
}

main "$@"
