import os 

dejaVus = []
truc = "References\n\n   Visible links"
# nbError = 0

try:
		with open("top.txt", "r") as f:
			content = f.readlines()
		
		for i in range(len(content)):
			if 'Visible links' in content[i]:
				 firstLink = i+1
				


		liens = []

		for line in content[firstLink:]:
			line = line.lstrip()
			mots = line.split(" ")
			if "." in mots[0] and "ssbwiki" in mots[1] and "4" not in mots[1] and ".png" not in mots[1] and ".jpg" not in mots[1] and ".php" not in mots[1] and "#" not in mots[1] and ".gif" not in mots[1] and ("Smasher" in mots[1] or "Tournament" in mots[1]):
				liens.append(mots[1].strip())
		for lien in liens:
			if lien not in dejaVus:
				print("checking if " + "./".join(lien.replace("https://www.ssbwiki.com/", "")) + " exists ... " + os.path.isfile("./".join(lien.replace("https://www.ssbwiki.com/", ""))))
				if not os.path.isfile("./".join(lien.replace("https://www.ssbwiki.com/", ""))): 
					print("je lance lynx sur " + lien)
					cmd = 'lynx "{0}" -dump -width=1024 > "{1}.txt"'.format(lien, lien.replace("https://www.ssbwiki.com/", ""))
					# print(cmd)
					os.system(cmd)
					print("j'ai fini lynx")
				
		for l in liens:
			if l not in dejaVus:
				print("je lance go sur " + l)
				dejaVus.append(l)
				go(l.replace("https://www.ssbwiki.com/", "").join(".txt"))
except Exception as e:
		print("Olalala" + "toplsl" + "buggggg !!!!!")
		print(str(e))
		# nbError = nbError + 1
		# print("C'est l'erreur numero   " + str(nbError))


def go(nomFichier):

	try:
		with open(nomFichier, "r") as f:
			content = f.readlines()
		
		for i in range(len(content)):
			if 'Visible links' in content[i]:
				 firstLink = i+1
				


		liens = []

		for line in content[firstLink:]:
			line = line.lstrip()
			mots = line.split(" ")
			if "." in mots[0] and "ssbwiki" in mots[1] and "4" not in mots[1] and ".png" not in mots[1] and ".jpg" not in mots[1] and ".php" not in mots[1] and "#" not in mots[1] and ".gif" not in mots[1] and ("Smasher" in mots[1] or "Tournament" in mots[1]):
				liens.append(mots[1].strip())
		for lien in liens:
			if lien not in dejaVus:
				print("je lance lynx sur " + lien)
				cmd = 'lynx "{0}" -dump -width=1024 > "{1}.txt"'.format(lien, lien.replace("https://www.ssbwiki.com/", ""))
				# print(cmd)
				os.system(cmd)
				print("j'ai fini lynx")
				
		for l in liens:
			if l not in dejaVus:
				print("je lance go sur " + l)
				dejaVus.append(l)
				go(l.replace("https://www.ssbwiki.com/", "").join(".txt"))
	except Exception:
		print("Olalala" + nomFichier + "buggggg !!!!!")
		# nbError = nbError + 1
		# print("C'est l'erreur numero   " + str(nbError))

