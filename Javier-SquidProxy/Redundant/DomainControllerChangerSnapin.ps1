$hn = hostname
#nltest /dsgetdc:ucdenver.pvt
nltest /Server:$hn /SC_RESET:ucdenver.pvt\Artemis
#nltest /dsgetdc:ucdenver.pvt
gpupdate /force