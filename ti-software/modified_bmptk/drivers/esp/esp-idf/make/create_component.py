#!/usr/bin/env python
import sys, os

workspace_dir = sys.argv[1]
component_path = sys.argv[2]
component_name = sys.argv[3]



def Create_build_dir():
	component_build_dir = workspace_dir+'/build/'+component_name
	if not os.path.isdir(component_build_dir):
		os.makedirs(component_build_dir)
	
	component_mk_file = open("component_project_vars.mk", "w")
	
print('a',workspace_dir)
print('b',component_path)
print('c',component_name)