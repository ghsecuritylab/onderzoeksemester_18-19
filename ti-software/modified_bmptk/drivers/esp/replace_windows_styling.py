#!/usr/bin/env python
import os, sys, subprocess
from subprocess import call

input = sys.argv[1]


idx = input.find(':')
if idx is not -1:
	for stringIdx, ch in enumerate(input):
		if ch == "\\":
			input = input[:stringIdx] + "/" + input[stringIdx+1:]
	idx -=1
	input = input[:idx] + "/" + input[idx].lower() + input[idx+2:]


	

print(input)
#exit(input)

#print("env1: "+os.environ["SUPER_SECRET_VARIABLE"])
#os.environ["SUPER_SECRET_VARIABLE"] = input

#print("env2: "+os.environ["SUPER_SECRET_VARIABLE"])
