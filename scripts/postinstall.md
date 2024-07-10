# Post Installation Steps   
## Networking   
```
systemctl start NetworkManager.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
```
## Add a User and disable root  
```
useradd -m -G wheel -c "Simon Booker" -s /bin/bash simon
passwd simon
```
Add simon to the sudo's file   
```
EDITOR=nvim visudo
#Uncomment the following value
#%wheel ALL=(ALL:ALL) ALL
```
Now logout and backin again as the new user  
**Test that sudo has been properly configured**
Lock out the root user  
```
sudo passwd -l root
```
## Enable Snapshoting   
First we need to download yay and yabsnap  
```
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```
Once yay has been installed...
```
yay -S yabsnap
```
#### Configure yabsnap  
```
sudo yabsnap create-config root
```
This will create a file at ```/etc/yabsnap/configs/root.conf```
Edit this file so than ```source``` = ```source = /```   
Enable the yabsnap timer service   
```
sudo systemctl enable --now yabsnap.timer
```
## Test snapshots
First create a snapshot
```
sudo yabsnap create --comment 'Test Snapshot'
yabsnap list # Should return a snapshot list containing 1 record (the snapshot we've just created)
```
Now create a file in the root of ```/```. We will then rollback and confirm that this file disappears.   
```
sudo touch /test_file.txt
Enter "This file should not be here" into /test_file.txt
```
Initate a rollback   
Find the correct timestamp for the rollback with ```yabsnap list```
```
yabsnap rollback-gen 20240710203230 | tee ~/rollback.sh
chmod +x rollback.sh
sudo ./rollback.sh
```
Reboot and log back in.
We should no longer see ```/test_file.txt```
We can now delete the test snapshot   
```
cat ~/rollback.sh
```
This will return the command needed to remove the now redundent snapshot  

## BTRFS filesystem maintainence  
```
sudo systemctl enable fstrim.timer
sudo systemctl enable btrfs-scrub@dev-disk-by.... .timer
```
