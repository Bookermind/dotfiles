# Arch installation guide (notes)

The aim of this is to install a vanila arch system.  
We will use btrfs with snapper snapshots on a single nvme drive.   
**Ensure secure boot is turned OFF before attempting to boot the live USB or install the system**   

## Initial System configuration

When booting the live USB confirm/set the following:  
System Keymap (United Kingdom keymap for me) 

```
loadkeys uk
```

Confirm we can access the internet:

```
ping -c 3 8.8.8.8
```

If the network is not accessible (on WIFI for example) set this up using nmcli.

Check and set the correct date and time.

```
timedatectl
```

## Hard Drive Partitions

Proposed HDD Partition Scheme (assuming single disk called vda):

```
partition   size        fs          label   fstype          mount
vda1        500M        fat32       EFI     EFISYSTEM       /boot/efi
vda2        4G          ext2        BOOT                    /boot
vda3        100%FREE    luks        cryptsys
```

### Prepare the disk

```
fisk /dev/vda
g (create new GPT partition table)
n (new partition)
ENTER, ENTER
+500M (last sector)
t (change partition type)
1 (EFI system)

n
ENTER, ENTER
+4G

n
accept defaults

w (write partition table)
```

### Format partitions

#### EFI Partition

```
mkfs.fat -F32 -n EFI /dev/vda1
```

#### BOOT Partition

```
mkfs.ext2 -L BOOT /dev/vda2
```

#### ROOT FileSystem   
First we need to format the create the luks encrypted volume, open it and create an lvm (for the actual filesystems)   
```
#Create Top level LUKS container
cryptsetup luksFormat /dev/vda3
cryptsetup luksOpen /dev/vda3 cryptsys

#Create LVM on LUKS
pvcreate /dev/mapper/cryptsys
vgcreate sys /dev/mapper/cryptsys
#Create two logical volumes (swap with a size equal to the machine's ram (to allow for suspend) and the rest as root
lvcreate -L 12G sys -n swap
lvcreate -l 100%FREE sys -n root
```
Format the newly created filesystems   
```
#Swap
mkswap /dev/mapper/sys-swap
swapon /dev/mapper/sys-swap
#Root
mkfs.btrfs -L ROOT -f /dev/mapper/sys-root
```
##### BTRFS subvolumes for root filesystem  
First mount the bare btrfs filesystem so we can create the needed directories and subvolumes   
```
mount /dev/mapper/sys-root /mnt
```
Create the required subvolumes   
```
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@var-cache
btrfs subvolume create /mnt/@var-spool
btrfs subvolume create /mnt/@var-tmp
btrfs subvolume create /mnt/@var-log
btrfs subvolume create /mnt/@var-lib-machines
btrfs subvolume create /mnt/@var-lib-docker
btrfs subvolume create /mnt/@var-lib-portables
btrfs subvolume create /mnt/@var-lib-libvirt
btrfs subvolume create /mnt/@usr-local
btrfs subvolume create /mnt/@.snapshots
```
Create the folder hierarchy   
```
umount /mnt
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@ /mnt
mkdir /mnt/{home,opt,srv,root,tmp}
mkdir /mnt/boot # (we can only create the efi directory once the actual boot partition is mounted)
mkdir -p /mnt/var/{cache,spool,tmp,log}
mkdir -p /mnt/var/lib/{machines,docker,portables,libvirt}
mkdir -p /mnt/usr/local
mkdir /mnt/.snapshots
```
Mount the subvolumes   
```
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@home /mnt/home
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@opt /mnt/opt
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@srv /mnt/srv
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@root /mnt/root
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@tmp /mnt/tmp
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-cache /mnt/var/cache
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-spool /mnt/var/spool
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-tmp /mnt/var/tmp
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-log /mnt/var/log
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-lib-machines /mnt/var/lib/machines
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-lib-docker /mnt/var/lib/docker
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-lib-portables /mnt/var/lib/portables
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@var-lib-libvirt /mnt/var/lib/libvirt
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@usr-local /mnt/usr/local
mount /dev/mapper/sys-root -o compress=zstd,discard=async,subvol=@/.snapshots /mnt/.snapshots
```
Mount remaining (non btrfs) filesystems   
```
mount /dev/vda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi
```
At this point check the filesystem and mounts with ```lsblk```  

## System installation  
Use pacstrap to install the base operating system   
```
#Pacstrap installation
pacstrap -K /mnt base base-devel linux-zen linux-firmware amd-ucode btrfs-progs lvm2 networkmanager neovim grub grub-btrfs git reflector man-db man-pages texinfo efibootmgr
```
This will install a base system with no graphics or desktop environment - it will stil take a while so be patient!   
```
genfstab -U /mnt >> /mnt/etc/fstab
```
It is a good idea at this point to check the generated fstab and correct anything that looks off: ```vim /mnt/etc/fstab```   

### Initial System Configuration   
Chroot into the new system with ```arch-chroot /mnt```   
```
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime #Set the localtime (UK for me)
hwclock --systohc
#Generate locales and set basic keymap, console and hostname
vim /etc/locale.gen # Uncomment the relevant locales (for me both en_GB lines)
locale-gen
echo "LANG=en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk" >> /etc/vconsole.conf
# Set your hostname (here assumed to be "hostname")
echo [hostname] >> /etc/hostname
vim /etc/hosts
```
The ```/etc/hosts``` file should look like the below:   
```
127.0.0.1        localhost
::1              localhost
127.0.0.1        [hostname].localdomain [hostname]
```
### Initramfs setup   
Edit the ```/etc/mkinitcpio.conf``` file. The hooks array should look like the below:   
```
HOOKS = (base udev autodetect modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)
```
Additionally place ```amdgpu``` in the modules array.   
This is required to ensure my amd graphics card is available in early user space.   
This is a requirement for plymouth but also (at least on my system) seems to be a requirement for the SDDM display manager.  

Regenerate the initramfs   
```
mkinitcpio -P
```
### GRUB bootloader (non secure boot)   
We will first install grub for efi without considering secure boot (so that we can ensure the system boots without secure boot and that we haven't done anything wrong up to now)   
Install the grub bootloader to the efi partition  

```
grub-install --target=x86_64_efi --efi-directory=/boot/efi --bootloader-id=ARCHLINUX
```
# If planning to implement secure boot using sbctl the grub install command is different   
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCHLINUX --modules="tpm" --disable-shim-lock
```
#### Configure grub to boot encrypted root   
We need to find the UUID of the hard disk partition containing our root luks container (in this setup this is /dev/vda3 which contains the cryptsys luks container)   
We can either do this using ```blkid```, ```lsblk -f``` and writing the relevant UUID down or using a text editor like neovim with a two tab layout.   
Once we have the correct UUID we need to update and generate the grub configuration   

```
vim /etc/default/grub
#Find GRUB_CMDLINE_LINUX: match -
cryptdevice=UUID=[UUID]:cryptsys:allow-discards root=/dev/sys/root
```

Generate the grub configuration with

```
grub-mkconfig -o /boot/grub/grub.cfg

```   
### Root Password
Set the root password with ```passwd```   

## REBOOT
