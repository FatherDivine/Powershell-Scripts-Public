The files needed to make everything work (Ubuntu host rename & AD join) are:

- rename_host_fog_linux (Controls everything, located on FOG server in /images/postdownloadscripts/. This file automatically copies ad_join.sh and crontab onto imaged computer. This file runs right after the image files are copied to the computer(s) by FOG. To enable/disable, edit /images/postdownloadscripts/fog.postdownload and either comment (#) or uncomment the line ". ${postdownpath}rename_host_fog_linux")

- crontab (Overwrites the original crontab at /etc/crontab. Sets ad_join.sh to automatically run after reboot, which is the first boot after being imaged.)

- ad_join.sh (Leaves realm, joins realm, restarts ssd, & reboots. Upon reboot AD login will work.)

- Custom_My_Master (To be ran on the Ubuntu install prior to being imaged. Purpose is to prep the Ubuntu installation for imaging (& AD use). Functions include Host Update (apt-get update/upgrade), Grub Configuration, Gnome authentication, & Enabling Fog service. Does *not* have to be ran but can automate the above tasks at once.

The only changes needed are to make partition selection automatic. At current the script (rename_host_fog_linux) has to manually be edited (Lines 95, 96: mount /dev/x /imagefs) with the correct partition that Ubuntu is on (/dev/sda5 or /dev/nvme0n1p5 etc). It is my hope to add intelligence in the script to automatically detect which partition is Ubuntu (by looking for a /etc or /opt folder).

How to use:

1.) login to fog-01 via ssh (KeePass = login info), and navigate to where the fog.postdownload file is:

cd /images/postdownloadscripts

2.) edit this file to enable the rename_host_fog_linux file (use any text editor you know how to use):
vi/nano/emacs fog.postdownload

in this file you should see:
. ${postdownpath}rename_host_fog_linux

Make sure there is no # before the dot '.' at the beginning of that line.

3.) open rename_host_fog_linux and make sure the partition that your Ubuntu install is located is correct on line 95-96. For instance, 2 hard drives of 2 different Dell computers are below. nvme0n1p# means the hard drive is an SSD embedded on the mobo, and sda# means it is the old school hard drive with the spinning disks:

                mount /dev/nvme0n1p5 /imagefs
		or
                #mount /dev/sda5 /imagefs


4.) With all other files in tact (including the ad_join_files folder within the /images/postdownloadscripts/ folder that contains crontab and ad_join.sh), run imaging as normal. At the end of the imaging, the script will run.



Extra Notes: 
If you are using this file outside of CU Denver's IT Dept, you must create (or copy via pscp) the files to the proper fog directories mentioned above 