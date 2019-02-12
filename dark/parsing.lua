local dark = require("dark")

-- *************** Partie DB *************** --
local db = {
	["players"] = {
		
	}
}


-- Fonction d'enregistrement des donnees extraites dans la BD
function registerindb(seq)
	pseudoTab = tagstring(seq, "#pseudo")
	if(pseudoTab ~= nil and #pseudoTab ~= 0) then
		pseudo = pseudoTab[1]
		
		-- Nom principal du player
		db["players"][pseudo] = {}
		db["players"][pseudo]["name"] = pseudoTab
		
		-- Mains
		local mains = tagstring(seq, "#main")
		db["players"][pseudo]["mains"] = mains
		
		-- Nationalite
		local nationality = tagstring(seq, "#nationality")
		db["players"][pseudo]["nationality"] = nationality
		
		-- Nicknames
		local nicknames = tagstring(seq, "#nickname")
		db["players"][pseudo]["nicknames"] = nicknames
	end
end

-- Permet d'extraire des sequences de dark les mots detectes
function tagstring (seq, tag, deb, fin)
	-- Valeurs par défauts pour les paramètres
	deb, fin = deb or 1, fin or #seq
	local tab = {}
	
	for idx, pos in ipairs(seq[tag]) do
		local d, f = pos[1], pos[2]
		if d >= deb and f <= fin then
			local res = ""
			for i = d, f do
				res = res .. seq[i].token
			end
			tab[#tab + 1] = res
		end
	end
	return tab
end 

-- ***************************************** --


-- *********** Partie Extraction *********** --

local P = dark.pipeline()
P:basic()
P:lexicon("#character", "lexicon/ssbm_characters.txt")
-- P:lexicon("#pseudo", "lexicon/pseudos.txt")

-- Detection des années
P:pattern([[ [#year /^([1-2][0-9][0-9][0-9])$/] ]])

-- Detection du rank
P:pattern([[ [#rank ( /^[0-9]+[tnrs][hdt]$/ )] ]])
P:pattern([[ [#globalRank #rank #w{0,4}? #year MPGR] ]])

-- Detection du pseudo du joueur
P:pattern([[ [#pseudo_ .]  ("(".{0,30}? ")" | /^[^.]+$/{0,30}?)  is ([#nationality #W] | #w)*  ( smasher | Melee player )]])
P:pattern([[ [#joueur [#pseudo #pseudo_] /^[^.]+$/{0,80}? (#character | #globalRank) ] ]])

P:pattern([[ from [#nationality #W] ]])
P:pattern([[ #pseudo (#w | "," | "(" | ")"){0,20}? from[#nationality #W] ]])

-- Detection des mains
P:pattern([[ [#main #character] (("," [#main #character])*? and [#main #character])? main]])
P:pattern([[ mains [#main #character] (("," [#main #character])*? and [#main #character])? ]])

-- Detection des surnoms du joueur (a completer) (?)
P:pattern([[ (also known as | aka | also referred to as (just)?) (( [#nickname ( #w | #W ){1,5}] ( and | "," | or){0,2} ){1,10} ( is | "." | ")"))? ]])

-- Detection des tournois 
P:pattern([[ ( winner of | won | winning )  ( [#tournoi #W{0,5}?] ( "," | and | ".")){0,5} ]])
P:pattern([[ facing .{0,3}? in .{0,2}? at [#tournoi .{0,5}?] ( "," | "." ) ]])

-- Detection des phrases (attention aux acronymes)
P:pattern([[ [#acronym (/^%u$/ ".")+ /^%u$/ ] ]])
P:pattern([[ [#sentence /^[A-Z]/ (#acronym | .)*? "."] ]])

-- ***************************************** --

local tags = {
	["#character"] = "blue",
	["#pseudo"] = "yellow",
	["#joueur"] = "yellow",
	["#nationality"] = "green",
	["#main"] = "blue",
	["#nickname"] = "green",
	["#year"] = "yellow",
	["#tournoi"] = "yellow",
	["#rank"] = "green",
	["#globalRank"] = "green",
}

local rep = "../WikiSmash"
for fichier in os.dir(rep) do
	for line in io.lines(rep.."/"..fichier) do
		line = line:gsub("%p", " %0 ")
		seq = dark.sequence(line)
		P(seq)
		print(seq:tostring(tags))
		print("\n")
		--Ajout des infos dans la bd
		registerindb(seq)
	end
end

-- Ecriture dans un fichier de toutes les informations
file = io.open("file.txt", "w")
file:write("return")
file:write(serialize(db))
io.close(file)


