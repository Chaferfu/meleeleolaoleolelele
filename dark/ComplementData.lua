local dark = require("dark")

-- *************** Partie DB *************** --

--db = do("file.txt")
local db = {
	["players"] = {
		
	}
}

-- Fonction d'enregistrement des donnees extraites dans la BD
function registerindb(seq, pseudo)
	if(db["players"][pseudo] == nil) then
		-- Nom principal du player
		db["players"][pseudo] = {}
		db["players"][pseudo]["pseudo"] = pseudo
	end
	local mains = tagstring(seq, "#main")
	if(mains ~= nill) then
		db["players"][pseudo]["mains"] = mains
	end
	-- Sponsors
	local sponsor = tagstring(seq, "#sponsor")
	db["players"][pseudo]["sponsor"] = sponsor

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
				if res == "" then
					res = seq[i].token
				else
					res = res .. " " .. seq[i].token
				end
			end
			tab[#tab + 1] = res
		end
	end
	return tab
end 

function tagstringlink(seq, link, tag)
	if not havetag(seq, link) then
		return
	end
	local pos = seq[link][1]
	local deb, fin = pos[1], pos[2]
	return tagstring(seq, tag, deb, fin)
end

function havetag(seq, tag)
	return #seq[tag] ~= 0
end

-- ***************************************** --


-- Data accessible en sucturé :
-- - pseudo (smasher: #pseudo)
-- - main (Melee main #main)
-- - sponsors (sponsor(s) #sponsor)
-- - rank (Ranking Super Smash Bros. Melee Summer 2018 MPGR: #rank)
-- - money (Winnings Super Smash Bros. Melee ~)
-- - name (Real name #name)
-- - birth + age (Birth date #birth (age #age))
-- - lieu (Location #ville ,)

-- *********** Partie Extraction *********** --
local P = dark.pipeline()
P:basic()
P:lexicon("#character", "lexicon/ssbm_characters.txt")
-- P:lexicon("#pseudo", "lexicon/pseudos.txt")

P:pattern([[ Smasher ':' [#pseudo #w{1,3}] ]])
P:pattern([[ Melee (main | mains) ([#main #character] ','?)* ]])
P:pattern([[ sponsor '(' s ')' [#sponsor #w{1,3}?] ','? ]])

-- -- Detection des années
-- P:pattern([[ [#year /^([1-2][0-9][0-9][0-9])$/] ]])

-- -- Detection du rank
-- P:pattern([[ [#rank ( /^[0-9]+[tnrs][hdt]$/ )] ]])
-- P:pattern([[ [#globalRank #rank #w{0,4}? #year MPGR] ]])

-- -- Detection du pseudo du joueur
-- P:pattern([[ [#pseudo_ .]  ("(".{0,30}? ")" | /^[^.]+$/{0,30}?)  is ([#nationality #W] | #w)*  ( smasher | Melee player )]])
-- P:pattern([[ [#joueur [#pseudo #pseudo_] /^[^.]+$/{0,80}? (#character | #globalRank) ] ]])

-- P:pattern([[ from [#nationality #W] ]])
-- P:pattern([[ #pseudo (#w | "," | "(" | ")"){0,20}? from[#nationality #W{0,3}] ]])

-- -- Detection des mains
-- P:pattern([[  [#main #character] (("," [#main #character])*? and [#main #character])? main]])
-- P:pattern([[ (mains | main) [#main #character] (("," [#main #character])*? and [#main #character])? ]])
-- P:pattern([[ (mains | main) [#main #character] ("/" [#main #character])+ ]])
-- P:pattern([[ best Melee? [#main #character] ]])

-- -- Detection des surnoms du joueur (a completer) (?)
-- P:pattern([[ (also known as (simply)?| aka | also referred to as (just)?) (( [#nickname ( #w | #W ){1,5}] ( and | "," | or){0,2} ){1,10}? ( is | "." | ")"))? ]])

-- -- Detection des tournois 
-- P:pattern([[ ( winner of | won | winning )  ( [#tournoi #W{0,5}?] ( "," | and | ".")){0,5} ]])
-- P:pattern([[ facing .{0,3}? in .{0,2}? at [#tournoi .{0,5}?] ( "," | "." ) ]])

-- -- Detection des phrases (attention aux acronymes)
-- P:pattern([[ [#acronym (/^%u$/ ".")+ /^%u$/ ] ]])
-- P:pattern([[ [#sentence /^[A-Z]/ (#acronym | .)*? "."] ]])

-- ***************************************** --

local tags = {
	-- ["#character"] = "blue",
	["#pseudo"] = "yellow",
	-- ["#joueur"] = "yellow",
	["#sponsor"] = "green",
	["#main"] = "blue",
	-- ["#nickname"] = "green",
	-- ["#year"] = "yellow",
	-- ["#tournoi"] = "yellow",
	-- ["#rank"] = "green",
	-- ["#globalRank"] = "green",
}
local pseudo = ""
local rep = "../Smashers"
for fichier in os.dir(rep) do
	for line in io.lines(rep.."/"..fichier) do
		line = line:gsub("%[[0-9]+%]", "")
		line = line:gsub("%p", " %0 ")
		seq = dark.sequence(line)
		P(seq)
		pseudoTab = tagstring(seq, "#pseudo")
		if(pseudoTab ~= nil and #pseudoTab ~= 0) then
			pseudo = pseudoTab[1]
		end

		--print(seq:tostring(tags))
		--print("\n")
		--Ajout des infos dans la bd
		if(pseudo ~= "") then
			registerindb(seq, pseudo)
		end
	end
end

-- Ecriture dans un fichier de toutes les informations
file = io.open("file2.txt", "w")
file:write("return ")
file:write(serialize(db))
io.close(file)
