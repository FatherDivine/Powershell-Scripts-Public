-------------------------------------------------------------------------------
Welcome to version 1.5.5 of LCHWC!

If you would like to work with modified versions of LCHWC, we encourage you to well document the changes of the script.

------------------------------------------------------------------------------------------------
Table of Contents
------------------------------------------------------------------------------------------------
   I	Additional Support
  II	File List
 III	Requirements
  IV	Command Line Arguments
   V	Design Decisions & Issues
  VI	Analysis
 VII	Expected /real Bottlenecks
VIII	THE STORY SO FAR
------------------------------------------------------------
I Additional support
------------------------------------------------------------
If you are looking for external help, look no further than the e-mail! aaron.staten@ucdenver.edu.

------------------------------------------------------------
II File list
------------------------------------------------------------
LCHWC-1.5.5.bat		  The main file
LCHWCMailer.ps1		  Powershell script used to e-mail the hardware comparison results
Changelog.txt		  All change notes
Readme.txt		  This file

------------------------------------------------------------
III Requirements
------------------------------------------------------------
Native windows environment. I made sure that the script would not need anything else but what comes with every version of windows (hence the use of Powershell for e-mail).


------------------------------------------------------------
IV Command Line Arguments
------------------------------------------------------------
Nada, but there is a test function. By right clicking LCHWC-1.5.5.bat and pressing edit, you can access the following test function on line 10 of code:
	if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )

Moving that line of code down 2 lines (basically right after :EndFirstComment) will allow one to keep the command prompt open for debugging purposes.


------------------------------------------------------------
V Purpose, Design Decision, & Implementation
------------------------------------------------------------
A. Purpose
The purpose of this script was to fill a need in the CEDC Laptop Checkout process. Before this script, there was no way to uniformly check if any changes were made to the hardware (eg: student swapped memory/SSD, broke the screen and had it repaired, record physical damage to the chassis). This script fulfilled this by using automation in a way that allows recording before and after a laptop is rented, as well as compare both files and keep record of any changes. 

B. Program design & Implementation
One design element was to make this script as automated as possible, with minimal tech intervention. Discreetness was baked in to add tamper-resistance of those using the laptops (Attrib/user rights lockdown). Another goal was to keep this as native as possible, requiring no additional software installation on the laptops. This was achieved by using batch scripting and Powershell for emailing. Lastly, plenty of commentary was baked in all files to create a model for other scripts that may come, as well as to clearlly communicate what each part does.

The script starts with an "admin rights" script to gain the rights needed. When executing the script, expect a UAC pop-up that needs to be clicked "yes" to here. Because of it's automation nature, the script automatically pulls the hardware using "wmic" commands and stores them in a file called "PreHardware.txt". Lastly, it asks the user for input for the Technician Notes section. If this is the second run, additionally it is e-mailed off (cedchelp@ucdenver.edu) and the user is asked if they would like HouseKeeping service. This service deletes the LCHWC folder located on cladmin Desktop which houses the PreHardare.txt, PostHardware.Txt, & Results file (Date-Serial.txt). The only reason not to delete these is if a user wanted to manually compare them or keep a copy of the hardware, as this is stripped from the Results file once no changes are detected. 

One design question learned thru Zuleyka's testing was what to do if a laptop came back and that was the first time we ran the script, as the script didn't exist prior? Unless a flag is set to ask if this is a laptop that was brought back and this script is running first time, the best choice is to run the code twice, and put technician notes on the second run only. While this won't compare the hardware to a time the script didn't exist, it will start the historical record for that Service Tag. In the case of Zuleyka's testing, we were able to record that the laptop (#33FD7D3) had a chip (chunk of plastic missing) on the physical hardware.

In design, I am always looking to make the code more clear and easily understandable regardless of background. So please feel free to send information as such to aaron.staten@ucdenver.edu with the subject: "LCHWC Requests".

------------------------------------------------------------
VI Analysis
------------------------------------------------------------
As of writing, the program is an effective solution to the original problem of detecting hardware tampering between laptop rentals. One bonus was the added benefit of technician notes in both Post and Pre, which allows the Technician to leave detailed information on all aspects of the laptop. This should range from what code can't pick-up: the physical appearence, paint damage, keyboard or screen/pixel damage, etc. This will leave a historical record for all CEDC technicians to back on in the event of damage.

------------------------------------------------------------
VII Bottlenecks, Issues, & Non-Implemented
------------------------------------------------------------
Some things I would like to implement, but may require extensive overhaul, and aren't worth the trouble (as of now):

- Unless the Technician leaves their name in the notes section, the person who checked the laptop out is unknown (would have to cross-reference with Julie's laptop checkout logs, historically). I suggest that the Technician leaves a note instead of automation. For it to be automated, the name would have to be pulled from an excel sheet, possibly cross-referencing with the Laptop # instead of Service Tag/Serial #. This would mean changes to the excel file used to record laptop checkins and checkouts. This would also mean the excel file would have to be of a static format with historical records. As of writing, the file only has active data for each laptop.

- Instead of a Records folder full of text files that are categories by Date-Serial.txt, this could all be put into a single MYSQL or likes database. We would have to have a front-end so all technicians can easily access in GUI function rather than via command prompt.

------------------------------------------------------------
VIII THE STORY SO FAR
------------------------------------------------------------
You're IT staff, one of Earth's toughest, hardend in repair and trained for success. Three years ago your superior officers had a meeting and requested sofware to document changes to laptop hardware. As evil can sometime come out of the Gateways, you were ordered to secure the perimeter of the base, which includes the laptop hardware. This part is an ode to Doom, a game released on December 10, 1992 by id Software. The style of this ReadMe was taken from the Readme.txt file from the PC shareware Doom version 1.8. "This edition of README.TXT includes a large amount of information that is missing from later editions of the file." I then added best practices, things like the roman numerals, to take it up to modern day standards.

-------------------------------------------------------------
LCHWC, the LCHWC logo and LCHWC likenesses are not trademarks of  
id Software, inc.,(C)1993. All other trademarks are the 
property of their respective companies.

-------------------------------------------------------------------------------