import os 

		with open("tournoi.txt", "r") as f:
			content = f.readlines()
		
		
		for line in content:
			lines = line.lstrip()
			if "Smasher" not in line and "File" not in line:
				print("je lance lynx sur " + line)
				cmd = 'lynx "{0}" -dump -width=1024 > "{1}.txt"'.format(line, line.replace("https://www.ssbwiki.com/", ""))
				os.system(cmd)
				print("j'ai fini lynx")
