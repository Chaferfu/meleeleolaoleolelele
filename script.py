import os 

dejaVus = []
truc = "References\n\n   Visible links"

with open("ppu.txt", "r") as f:
	content = f.readlines()
	
for i in range(len(content)):
	if 'Visible links' in content[i]:
		 firstLink = i+1
		


liens = []

for line in content[firstLink:]:
	line = line.lstrip()
	mots = line.split(" ")
	if "." in mots[0] and "ssbwiki" in mots[1] and ".png" not in mots[1] and ".jpg" not in mots[1] and ".php" not in mots[1] and "#" not in mots[1] and ".gif" not in mots[1]:
		liens.append(mots[1].strip())

for lien in liens:
	cmd = "lynx '{0}' -dump -width=1024 > '{1}.txt'".format(lien, ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10)))
	print(cmd)
	# os.system(cmd)