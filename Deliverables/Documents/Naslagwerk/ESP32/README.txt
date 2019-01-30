
In this file you will find the instructions to let the ESP-32 work vor Arduino IDE on Windows 10


Download and install the driver for CP210x for USB to UART bridge from silabs:
https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers


Setup the esp-32 driver for Arduino Due:
----------------------------------------
	- Step 1: Download the driver from GitHub:
				https://github.com/espressif/arduino-esp32
	- Step 2: Extract the files in ~/Arduino/hardware/espressif/esp32
				(NOTE: The folders /hardware/espressif/esp32 probably have to me bade manualy.)
	- Step 3: Run get.exe



	
	
Setup Arduino IDE
-----------------
	Open Device Manager.
	Check COM port the ESP-32 is set.
	Open the properties of the driver and set the Bits per second to  115200.

	Open Arduino IDE.
	Set Tools-->Board to "ESP Dev Module"
	Set Tools-->Uploadspeed to 115200
	Set Tools-->Flash Frequency to 40MHz
	Set Tools-->Port to the COM port the ESP-32 is set.





	

PROBLEMS
--------
	Problem: 
		"xtensa-esp32-elf-g++ file not found"
	Solution: 
		Check if xtensa-esp32-elf-win32-1.22.0-80-g6c4433a-x.x.x.zip is located in hardware/espressif/esp32/tools/dist
		If it is not located there, you can download it from: https://dl.espressif.com/dl/xtensa-esp32-elf-win32-1.22.0-80-g6c4433a-5.2.0.zip
		When the zip file is extracted, you should get a folder named "xtensa-esp32-elf".
		Place this folder in hardware/espressif/esp32/tools.


	Problem:
		"esptool.exe not found"
	Solution:
		Open hardware/espressif/esp32/package_esp32_index.template.json and look for the host version.
		For windows there should be a line saying  "host": "i686-mingw32".
		Download the esptool from: https://dl.espressif.com/dl/esptool-4dab24e-windows.zip
		Extract the esptool.exe in /hardware/espressif/esp32/tools/esptool
		(NOTE: For additional information see https://desire.giesecke.tk/index.php/2018/04/02/get-exe-get-py-fails-to-download-required-files/)


	Problem:
		"esp32 no headers files found in ~/libraries/AzureIoT"
	Solution:
		Download the library from https://github.com/VSChina/ESP32_AzureIoT_Arduino/tree/67dfa4f31ef88b0938dd87d955612100dea5562e.
		Place the files in ~/libraries/AzureIoT.


	Problem:
		"esp32 no headers files found in ~/libraries/BLE"
	Solution:
		Download the library from https://github.com/nkolban/ESP32_BLE_Arduino/tree/7951347ed68313d75c367e1f2cce763cb56d1eb2.
		Place the files in ~/libraries/BLE.


		
		




