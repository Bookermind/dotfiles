# Secure boot Installation   
**IMPORTANT**   
Ensure the following:
1. That your computer has a TPM chip   
2. That GRUB has been installed to utilise the TPM chip and disable shim lock (this will prevent grub from trying to side load additional modules and failing the secure boot checks).   
3. **That your computer is in Secure Boot setup mode**  
4. Install sbctl ```pacman -S sbctl```   
## Checking secure boot setup mode   
Boot into the UEFI firmware interface.   
Look for the secure boot section. You should either see a secure boot mode (this will need to read "Setup") or under key management you should see that no keys are in the secure boot key database.   
Checking secure boot mode is also possible from the commmand line of the system.   
```sudo sbctl status```   

**If there is anything indicating that you are not in setup mode STOP HERE**

### Getting into Setup Mode from User Mode   
If your computer is currently in User Mode (either with secure boot active or inactive) you need to get into setup mode before continuing.  The means of doing this differ for each fireware interface; however:  
1. Within the firmware interface you may be able to reset the database into setup.
2. Deleting the Platform Key (PK) will have the same effect.
    However both of these may be denied by secure boot policy.
3. Search in the firmware interface for CSM (Compatability Support Module) - changing this from enabled to disabled can sometimes unblock the above security settings.
4. Within the operating system ``` sube sbctl reset``` can also remove the PK if secure boot has been half completed but blocked by the firmware (usually when the systerm wasn't correctly in setup in the first place).   
5. If you are told by the firmware to try again after a reboot, it really means a reboot (usually easier to power cycle the computer) and not a reset.   

## Enabling secure boot   
Once the computer is in setup mode ```sbctl``` can be used to enable secure boot.   
First confirm the system status with ```sudo sbctl status```   
Now we create the new system keys (the PK)   

```
sudo sbctl create-keys
```

Enroll your keys **along with Microsoft's keys** into the UEFI

```
sudo sbctl enroll-keys -m
```

At this point we can check the secure boot status again with ```sude sbctl status``` and see that we now have an Owner ID.   
At this point we need to sign the files used during the boot process. ```sude sbctl verify``` can be used **however** have found that is does not return all the files needing to be signed.   
Commonly the files needing to be signed are the kernel image and the efi bootloader, in my case (following the install guide in this repository) these are:   

```
sudo sbctl sign -s /boot/vmlinuz-linux-zen
sudo sbctl sign -s /boot/efi/EFI/ARCHLINUX/grubx64.efi
```

Finally **reboot** into the firmware interface (you should now see the secure boot mode as "User") and enable secure boot.   
Reset the system and let the computer boot through to the operating system - any issues at this point will almost certainly be the result of secure boot signing issues. Reboot, turn off secure boot and try again (ensure that grub has been installed in the right way (see install guide).   

Once rebooted you can confirm secure boot using ```sude sbctl status``` which should read:   

```
Installed:          sbctl is installed
Owner GUID:         [your GUID]
Setup Mode:         Disabled
Secure Boot:        Enabled
Vendor Keys:        microsoft
```
