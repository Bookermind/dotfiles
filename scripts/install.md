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


