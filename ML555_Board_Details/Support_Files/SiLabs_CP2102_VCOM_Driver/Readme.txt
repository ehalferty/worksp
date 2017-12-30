CP210x Evaluation Kit CD v3.1 Release Notes
Copyright (C) 2005 Silicon Laboratories, Inc.

This release contains the following components:

* Driver Unpack Utility (CP210x_Drivers.exe) 
* Readme.txt (this file)
* Documentation directory
	* CP2101 Datasheet 
	* CP2102 Datasheet
 	* CP2103 Datasheet 
	* CP2101 Evaluation Kit User's Guide 
	* CP2102 Evaluation Kit User's Guide 
	* CP2103 Evaluation Kit User's Guide 
	* AN144: CP210x Customization Guide 
	* AN197: Serial Communications Guide for CP210x
	* AN205: CP210x Baud Rate Support
	* AN220: USB Driver Customization
	* AN223: Port Configuration and GPIO for CP210x
* Software directory
	* AN144SW: CP210x Customization software 
	* AN197SW: Serial Communications Sample Software
	* AN205SW: CP210x Baud Rate Support Sample Software
	* AN220SW: USB Driver Customization Sample Software 
	* AN223SW: CP210x Port Configuration and GPIO Examples


Driver Installation
-------------------

	Follow the steps below to uninstall previous driver versions
	and to install the new drivers included in this package. See 
	the Evaluation Kit User's Guide for further driver 
	installation instructions. 


	1) Unplug any connected CP210x devices.
	2) Remove old drivers that have previously been installed. 
	   For Windows systems, open the Add or Remove Programs 
	   window from the Control Panel. Next, select each CP210x
	   entry and click on Remove.
	3) Run the driver executable, CP210x_Drivers.exe, to extract 
	   all of the device drivers included with this release 
	   (Windows, Macintosh and Linux). The default installation 
	   directory for this release is "C:\Silabs\Mcu\CP210x".
	4) Connect a CP210x device.
	5) Install the new drivers. For Windows systems, the Add New 
	   Hardware Wizard should open when a new device is detected. 
	   Use the wizard to install the drivers by directing it to 
	   the "C:\SiLabs\MCU\CP210x\WIN" directory created in step 3. 
	6) See the Evaluation Kit User's Guide for further driver
	   installation instructions.


Known Issues and Limitations
----------------------------

	Current devices supported are CP2101, CP2102 and CP2103.

	This release now includes a PreInstaller.exe installer for the
	Windows drivers. After running the preinstaller, the Windows 
	Found New Hardware Wizard should not be need on Windows 98SE/2000.
	When using Windows XP with WHQL uncertified drivers, the Found 
	New Hardware Wizard will still appear.	

	This release does not include the MacIntosh OS9 driver. 
	It is available by request from the factory.

	The naming conventions for the Windows drivers has been changed
	from CP2101 to CP210x to include support for future CP210x 
	devices. The drivers included with this release can be used with 
	any device in the CP210x family. However, a WHQL certified 
	version of the Windows driver does not yet include this change.
	The device strings will say CP2101. This is a cosmetic change
	only. The drivers will still function for any CP210x device.

	This driver release package includes the following drivers:
		* CP210x Linux Driver v0.81b
		* CP210x Macintosh OSX Driver v1.00
		* CP210x Windows 98SE/2000/XP Driver v4.28


CP210x Evaluation Kit CD Revision History
------------------------------------------

Version 3.1

	New features/Enhancements
	-------------------------
	Support added for CP2103.	
	
	Updated to latest version of the CP210x drivers, v4.28.
	

	Corrections
        -----------
	Windows Drivers,
	Fixed problem Description: Set Line Control command called 
	with an invalid parameter causes hyperterminal to lock.

	Windows Drivers, 
	Fixed problem Description: For Windows 98, if no Xon or Xoff 
	limit is specified, the driver may set them both to zero. 
	This causes logical errors in device regarding flow control.

Version 3.0

	New features/Enhancements
	-------------------------
	Linux drivers updated from v0.81a to v0.81b.

	AN197 and AN197SW added to documentation and software directories
	on the CD.

	CP2102 datasheet and Eval Kit User's Guides added to documentation 
	directory on the CD.

	CP210x Custom Installation Wizard (in AN144SW.zip) has been updated
	to produce the newest Preinstaller.exe and Uninstaller.exe for Win2K/XP.

	Naming conventions changed from CP2101 to CP210x to include support
	for the new CP2102 device.

	Corrections
        -----------
	Linux Driver v0.81b: This version fixes an issue which caused a machine 
	crash when disconnecting from a modem (for Linux drivers only).

	Windows Drivers: Issue when using quiet mode in preinstaller fixed.

	Windows Drivers: Issue calling preinstaller from a directory which is not the current fixed.

	Windows Drivers: Updated preinstaller to support Windows 98SE.


Version 2.1

	New features/Enhancements
	-------------------------
	Windows Driver V4.20: Changed driver binary file names from cyg_* to slab*.  
	Also changed default inf file strings to SLAB and Silicon Laboratories.

	Windows Driver V4.20: This installation includes catalog files for Windows 
	2000/XP Windows Hardware Quality Lab (WHQL) Certification.

	Corrections
        -----------
	Windows Driver V4.20: Modified behavior of SERIAL_EV_TXEMPTY event 
	notification. Applications will no longer miss TXEMPTY events if a 
	write is pending during the IOCTL_SERIAL_WAIT_ON_MASK control request.


Version 2.0

	New features/Enhancements
	-------------------------

	Drivers for Linux v2.40 and greater have been added.

	A Windows driver customization utility has been added to 
	the latest version of AN144SW.zip. This file is included 
	with this release.

	Changed Windows driver binary file names from cyg_* to 
	slab*. Also changed default inf file strings to SLAB and 
	Silicon Laboratories.

	This installation includes catalog files for Windows 2000/XP 
	Windows Hardware Quality Lab (WHQL) Certification.

	
	Corrections
        -----------

	The new driver uninstaller for Windows 2000/XP now checks for 
	shared driver conflicts.

	Windows driver installation procedure now uses the Found New 
	Hardware Wizard instead of a preinstaller.	

	Windows drivers: Modified behavior of SERIAL_EV_TXEMPTY event 
	notification. Applications will no longer miss TXEMPTY events 
	if a write is pending during the IOCTL_SERIAL_WAIT_ON_MASK 
	control request.


Version 1.1


	New features/Enhancements
	-------------------------
	
	Corrections
        -----------

	Window drivers: Changed behavior for IOCTL_SERIAL_LSRMST_INSERT 
	for correct modem event insertion.


Version 1.0
	
	Initial Release


