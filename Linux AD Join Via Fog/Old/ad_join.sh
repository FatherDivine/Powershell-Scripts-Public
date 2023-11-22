#!/bin/bash
#########################################################
# Join Ubuntu to AD
#########################################################
FLAG="/var/log/firstboot.log"
if [[ ! -f $FLAG ]]; then

	echo "This is the first boot."
	sudo realm leave
	dhclient
	echo 'lUjZwCQlCGk5J!1xUEwT8qqs' | realm join -vvv -U svc-ceas-fog UCDENVER.PVT
	cp "/etc/sssd/sssd.conf.bak" "/etc/sssd/sssd.conf"
	#sudo service sssd restart > /dev/null
	sudo systemctl restart sssd
	sudo dhclient
	echo "Done."

	touch "$FLAG"
else
	echo "Did not run (else)"
fi

