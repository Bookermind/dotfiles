# Fedora (KDE) workstation setup dotfiles
This repository contains my personal dotfiles and associated setup files.  
While designed to run on Fedora the principals should be adaptable to other Linux distributions.  

# Organisation
The repo is organised into a series of folders - one folder per application being managed. For example ```zsh``` contains all my config files for zsh. Note however that some configurations depend on others - zsh for example envokes starship, whoch os also managed in this repo.  

# Functionality
Each folder contains all the configuration files needed to configure that application (with the above mentioned caveat). The management of these dotfiles is acheived through GNU stow.  

# Setup
At the root of the repo is a ```setup.sh``` file - this is designed as the point of entry into the setup process.  
It will install all needed packages as well as setting up RPMFusion and Terra repositories on the system. Copr is also used to install mise-en-place.  
Some application configurations contain sensitive data.  
These are encryped at rest (in this repo).

The setup script will install the necessary tooling to handle the decryption of these files. The script will also decrypt said files - this happens before stow synlinks thw config files.  
In order for the script to handle decryption three environment variables **MUST** be present on the system:  
- VAULTWARDEN_URL
- BW_CLIENTID
- BW_CLIENTSECRET

```bash
export VAULTWARDEN_URL="https://vault.foo.com"
export BW_CLIENTID="secretclientID"
export BW_CLIENTSECRET="supersecretclientsecret"
```
To find these in Vaultwarden go to your user settings.  
Under security look for a Keys section.  
In that section should be a "View API Key" button.

In a clean fedora installation export the three environment variables, make sure the setup script is executable and run it:
```bash
chmod +x setup.sh
./setup.sh
```

# Note on SSH keys
The setup script will place a systemd service in your user directories - this systemd service is used to automate the unlocking of SSH keys under KDE.   
Gnome uses a custom piece of functionality in Gnome Keyring to automate the unlocking and storing of SSH Keys in your gnome keyring - KDE does not have this. The systemd service, associated files and some terminal config bring this into KDE.  
Therefore after the script symlinks the service you will need to enable it to run as a user systemd unit.
```

```
