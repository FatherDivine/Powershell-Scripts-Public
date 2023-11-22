#!/bin/bash
#########################################################
# Join Ubuntu to AD. Created by GO DJ Haka (CU Denver, Greets from the Mile High City!) 10-13-2022
#########################################################

# First check if script has sudo/root, if not get it.
if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
fi

#########################################################
# The Guts: Leave Domain, rejoin domain, copy correct sssd.conf, 
# & restart SSSD (& PC) for changes to take place. Don't forget 
# to update the below code with your own user account with 
# the power to join PCs to domains, as well as the Domain. 
# The sssd.conf.bak should be created prior to imaging with the correct
# settings for the Domain. Anytime you leave the domain (realm leave) ,
# sssd.conf is overwritten, thus we rename it as sssd.conf.bak prior. 
#########################################################

FLAG="/var/log/firstboot.log"
if [[ ! -f $FLAG ]]; then

	echo "This is the first boot."
	realm leave
	sleep 8
	echo 'PasswordHere' | realm join -vvv -U UserHere Domain.HERE
	sleep 7
	cp "/etc/sssd/sssd.conf.bak" "/etc/sssd/sssd.conf"
	service sssd restart > /dev/null
	systemctl restart sssd
	echo "Done."

	touch "$FLAG"
	sleep 3
	#grub-reboot 1
	init 6
else
	echo "Did not run (/var/log/firstboot.log detected)"
fi
