
with open("_tournoi.txt", "r") as f:
	content = f.readlines()

with open("lexique_tournois.txt", 'w') as f:
	for line in content:
		if "Smasher" not in line and "File" not in line and ".php" not in line:
			tournoi = line.replace("https://www.ssbwiki.com/", "").replace("_", " ").replace("Tournament:", "")
			f.write(tournoi)
