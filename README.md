# CMangos Setup Script

This script automates the installation and configuration of CMangos with playerbots and ahbot.

## What it does

- **Checks for Root Privileges**: Ensures the script is run with root permissions.
- **OS Verification**: Confirms that the script is being run on Ubuntu 22.04.
- **Dependency Installation**: Automatically installs all necessary packages and dependencies required for CMangos.
- **Directory Creation**: Sets up the necessary directory structure for CMangos.
- **Repository Cloning**: Clones the CMangos core, playerbots, and classic database repositories from GitHub.
- **Project Building**: Compiles the CMangos project using CMake and installs the binaries.
- **Configuration File Setup**: Copies and configures the necessary configuration files for the server.
- **Database Installation**: Sets up the MySQL database and configures it according to the user's specifications.
- **Systemd Service Setup**: Creates systemd service files for managing the CMangos server processes.
- **Realmlist IP Configuration**: Prompts the user to change the realmlist IP for connecting to the server.

## Prerequisites

- A clean installation of Ubuntu 22.04.
- Root access to the server.
- An internet connection to download dependencies and repositories.
- MySQL server should be installed and running.

## Usage

1. **Download the Script**: Clone or download this repository.
2. **Make the Script Executable**: Run the following command:
   ```bash
   chmod +x setup_script.sh
   ```
3. **Execute the Script**: Run the script with root privileges:
   ```bash
   sudo ./setup_script.sh
   ```
**Follow the Prompts**: The script will guide you through the setup process. You will have the option to change the realmlist IP.

## Important Notes
Currently, the script does not support Client Data Extraction and that should be done manually using the tools provided in `~/cmangos/run/bin/tools/`

After running the script, you will need to modify the `mangosd.conf` file to disable the console for the systemd service to function correctly. Look for the line `Console.Enable` and change its value to `0`.
You can enable the services using the following commands after modifying the configuration:
   ```bash
   sudo systemctl enable realmd
   sudo systemctl enable mangosd
   ```
## Limitations
This script is specifically designed for Ubuntu 22.04. Running it on other operating systems may result in errors.
The script does not handle the creation of game accounts; you will need to do this manually after the installation.
It does not include any additional configurations for custom settings or modifications to the game.

## Acknowledgements
[davidonete](https://github.com/davidonete) for his docker script that inspired this one
[Celguar](https://github.com/cmangos/playerbots) for the new playerbots module
[ike3](https://github.com/ike3) for the original playerbots module
[CMangos](https://github.com/cmangos) for their open-source project.
[CMake](https://cmake.org/) for the build system.

Feel free to modify any sections to better suit your project
