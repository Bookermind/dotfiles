# Arch installation guide (notes)

The aim of this is to install a vanila arch system.  
We will use btrfs with snapper snapshots on a single nvme drive.

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
mkfs.fat -F32 -nEFI /dev/vda1
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
lvcreate -L12G sys -n swap
lvcreate -l 100%FREE sys -n root
```
Format the newly created filesystems   
```
#Swap
mkswap /dev/mapper/sys-swap
swapon /dev/mapper/sys-swap
#Root
mkfs.btrfs -L root -f /dev/mapper/sys-root
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
btrfs subvolume create /mnt/@var/cache
btrfs subvolume create /mnt/@var/spool
btrfs subvolume create /mnt/@var/tmp
btrfs subvolume create /mnt/@var/lib/machines
btrfs subvolume create /mnt/@var/lib/docker
btrfs subvolume create /mnt/@var/lib/portables
btrfs subvolume create /mnt/@var/lib/libvirt
btrfs subvolume create /mnt/@usr/local
btrfs subvolume create /mnt/@/.snapshots
```

