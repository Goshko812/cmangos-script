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

    echo "Select the version to compile:"
    echo "1) Classic (Vanilla)"
    echo "2) The Burning Crusade (TBC)"
    read -p "Enter your choice (1-2): " version_choice
}

create_directories() {
    mkdir -p $HOME/cmangos/build
    mkdir -p $HOME/cmangos/run/etc
    cd $HOME/cmangos || exit
}

clone_repositories() {
    if [[ "$version_choice" -eq 1 ]]; then
        git clone https://github.com/cmangos/mangos-classic.git mangos
        git clone https://github.com/cmangos/classic-db.git db
    elif [[ "$version_choice" -eq 2 ]]; then
        git clone https://github.com/cmangos/mangos-tbc.git mangos
        git clone https://github.com/cmangos/tbc-db.git db
    else
        echo "Invalid version option. Please select a valid version."
        exit 1
    fi
}

build_project() {
    cd $HOME/cmangos/build || exit
    cmake ../mangos -DCMAKE_INSTALL_PREFIX=$HOME/cmangos/run -DBUILD_EXTRACTORS=ON -DPCH=1 -DDEBUG=0 -DBUILD_PLAYERBOTS=ON -DBUILD_AHBOT=ON
    make -j$(nproc)
    make install
}

copy_configs() {
    cd $HOME/cmangos/run/etc || exit
    cp mangosd.conf.dist mangosd.conf
    cp realmd.conf.dist realmd.conf
    cp $HOME/cmangos/mangos/src/game/AuctionHouseBot/ahbot.conf.dist.in ahbot.conf
    cp anticheat.conf.dist anticheat.conf
    cp aiplayerbot.conf.dist aiplayerbot.conf
}

install_databases() {
    cd $HOME/cmangos/db || exit
    yes 9 | head -n 1 | ./InstallFullDB.sh
    sed -i "s|CORE_PATH=.*|CORE_PATH=\"${HOME}/cmangos/mangos\"|" InstallFullDB.config
    sed -i 's|AHBOT=.*|AHBOT="YES"|' InstallFullDB.config
    sed -i 's|PLAYERBOTS_DB=.*|PLAYERBOTS_DB="YES"|' InstallFullDB.config
    sed -i 's|MYSQL_PASSWORD=.*|MYSQL_PASSWORD="mangos"|' InstallFullDB.config
    sudo ./InstallFullDB.sh
}

change_realmlist_ip() {
    if [ "$version_choice" == "1" ]; then
        db_name="classicrealmd"
    elif [ "$version_choice" == "2" ]; then
        db_name="tbcrealmd"
    fi

    read -p "Do you want to change the realmlist IP? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        read -p "Enter your public or LAN IP: " ip_address
        sudo mysql -u root -p -e "USE $db_name; UPDATE realmlist SET address = '$ip_address' WHERE id = 1;"
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

   echo "[Unit]
Description=Restart Mangosd every 5 hours

[Timer]
OnBootSec=5h
OnUnitActiveSec=5h

[Install]
WantedBy=timers.target" | sudo tee /etc/systemd/system/mangosd.timer

   sudo systemctl daemon-reload
   
}

extract_game_data() {
    read -p "Do you want to extract game data from $HOME/client/? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        if [ -d $HOME/client/ ]; then
            echo "Extracting game data from $HOME/client/..."
            echo "Copying extractor files to your WoW client directory..."
            cp $HOME/cmangos/run/bin/tools/* $HOME/client/

            echo "Setting executable permissions on extraction scripts..."
            chmod +x $HOME/client/ExtractResources.sh $HOME/client/MoveMapGen.sh

            echo "Ensure the Data directory starts with an uppercase D in your WoW client directory."
            echo "Running the data extraction..."
            cd $HOME/client || exit
            bash ./ExtractResources.sh

            echo "Extraction complete! Moving extracted folders to $HOME/cmangos/run/bin..."
            mv maps $HOME/cmangos/run/bin/
            mv dbc $HOME/cmangos/run/bin/
            mv vmaps $HOME/cmangos/run/bin/
            if [ -d "mmaps" ]; then
                mv mmaps $HOME/cmangos/run/bin/
            fi
            if [ -d "CreatureModels" ]; then
                mv CreatureModels $HOME/cmangos/run/bin/
            fi
            if [ -d "Cameras" ]; then
                mv Cameras $HOME/cmangos/run/bin/
            fi

            echo "If you didn't find the CreatureModels folder, don't worry, it's optional."
        else
            echo "Directory $HOME/client/ does not exist. Please ensure the game client is located there."
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
    After Console.Enable is set to 0 you can do systemctl enable realmd and systemctl enable mangosd and optionally enable and start the mangosd.timer which will restart the game world every 5 hours"
}

main "$@"
