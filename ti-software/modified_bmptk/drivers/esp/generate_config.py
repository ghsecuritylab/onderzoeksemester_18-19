#!/usr/bin/env python
import sys
import os


idf_path  = sys.argv[1]
build_dir = sys.argv[2]
kconfig_tool_dir = sys.argv[3]
parameter  = sys.argv[4]
arguments = []



if (len(sys.argv)>5):
	for arg in sys.argv[5:]:
		arguments.append(arg)


def createFolder(directory):
	try:
		if not os.path.exists(directory):
			os.makedirs(directory)
	except OSError:
		print('Error: Creating directory. ',directory)


createFolder(str(build_dir+'/include/config'))


createDir = 'mkdir -p '+build_dir+'/include/config'
setVars = [('SET KCONFIG_AUTOHEADER='+build_dir+'/include/sdkconfig.h'),('SET IDF_CMAKE=n')]



KconfCommand = str(kconfig_tool_dir+'/'+parameter)+' '
for arg in arguments:
	KconfCommand += arg+' '
KconfCommand += idf_path+'/Kconfig'



os.system(createDir)
os.chdir(build_dir)
for var in setVars:
	os.system(var)
os.system(KconfCommand)




