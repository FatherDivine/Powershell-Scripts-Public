#Used to remove temp files like the ADS installer since the reinstall hangs on
#installing ADS. To fix in the live script, just remove -wait- from the start-process
#cmdlet but also put a long pause of at least 4-5 mins to allow the installer
#to actually finish installing before deleting.