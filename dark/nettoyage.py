import glob
import os
import re
path = '../Smashers'
for filename in glob.glob(os.path.join(path, '*.txt')):
	f = open(filename,"r")
	lines = f.readlines()
	f.close()
	f = open(filename,"w")
	for line in lines:
		if "http" not in line:
			f.write(re.sub('[[0-9]*]', '', line))
	f.close()
