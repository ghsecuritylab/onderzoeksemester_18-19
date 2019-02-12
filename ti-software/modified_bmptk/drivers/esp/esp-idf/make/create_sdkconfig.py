#!/usr/bin/env python
import sys, os

build_dir = sys.argv[1]
workspace_dir = sys.argv[2]
sdkconfig_dir = build_dir+'/include'

def create_sdk_header():
	if not os.path.isdir(build_dir):
		os.makedirs(build_dir)
	
	if not os.path.isdir(sdkconfig_dir):
		os.makedirs(sdkconfig_dir)
		
	with open(workspace_dir+'/sdkconfig') as f:
		content = f.readlines()
		
	content = [x.strip() for x in content]
	removals = []
	for lineIdx, line in enumerate(content):
		if len(line) <1:
			removals.append(lineIdx)
		elif line[0] == '#':
			removals.append(lineIdx)
	
	for rem in removals:
		content[rem] = 'xxxxx'
	b = []
	for lineIdx, line in enumerate(content):
		conf = line.split('=')
		if len(conf) > 1 and len(conf[1])>0:
			b.append(conf)
	
	sdk_head_file = open(sdkconfig_dir+'/sdkconfig.h', "w")
	for x in b:
		name = x[0]
		value = x[1]
		if value == 'y':
			value = 1
		sdk_head_file.write('#define '+name+' '+str(value)+'\n')
	sdk_head_file.close()
	
	
	
	
create_sdk_header()

