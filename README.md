# CMangos Setup Script

This script automates the installation and configuration of CMangos with playerbots and ahbot.

## What it does

- **Checks for Root Privileges**: Ensures the script is not ran with root permissions.
- **OS Verification**: Prompts the user to select their OS.
- **Dependency Installation**: Prompts the user to chose an expansion and then automatically installs all necessary packages and dependencies required for CMangos.
- **Directory Creation**: Sets up the necessary directory structure for CMangos.
- **Repository Cloning**: Clones the CMangos core, playerbots, and classic database repositories from GitHub.
- **Project Building**: Compiles the CMangos project using CMake and installs the binaries.
- **Configuration File Setup**: Copies and configures the necessary configuration files for the server.
- **Database Installation**: Sets up the MySQL database and configures it according to the user's specifications.
- **Systemd Service Setup**: Creates systemd service files for managing the CMangos server processes.
- **Realmlist IP Configuration**: Prompts the user to change the realmlist IP for connecting to the server.
- **Extract files from the client**: Prompts the user to extract the data files from the client.

## Prerequisites

- Ubuntu 20.04-22.04, Debian or Arch Linux.
- Root access to the server and an internet connection to download dependencies and repositories.
- MySQL server should be installed and running.
- Copy of the client in `~/client` (OPTIONAL)

## Usage

1. **Download the Script**: Clone or download this repository.
2. **Make the Script Executable**: Run the following command:
   ```bash
   chmod +x setup_script.sh
   ```
3. **Execute the Script**: Run the script without root privileges:
   ```bash
   ./setup.sh
   ```
**Follow the Prompts**: The script will guide you through the setup process. You will have the option to change the realmlist IP and extract the client data.

## Important Notes
After running the script, you will need to modify the `mangosd.conf` file to disable the console for the systemd service to function correctly. Look for the line `Console.Enable` and change its value to `0`.
You can enable the services using the following commands after modifying the configuration:
   ```bash
   sudo systemctl enable realmd.service
   sudo systemctl enable mangosd.service
   ```
You can see domain guide [here](https://github.com/Goshko812/cmangos-script/blob/main/domain.md)
and if you want to monitor your server you can see the guide [here](https://github.com/Goshko812/cmangos-script/blob/main/monitoring.md)
## Limitations
The script does not handle the creation of game accounts; you will need to do this manually after the installation.
It does not include any additional configurations for custom settings or modifications to the game.

## Acknowledgements
[davidonete](https://github.com/davidonete) for his docker script that inspired this one

[Celguar](https://github.com/cmangos/playerbots) for the new playerbots module

[ike3](https://github.com/ike3) for the original playerbots module

[CMangos](https://github.com/cmangos) for their open-source project.

[CMake](https://cmake.org/) for the build system.
