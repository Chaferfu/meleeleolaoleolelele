local dark = require("dark")

count = 0

local dataAjoute = 0
-- *************** Partie DB *************** --
local db = {
	["players"] = {
		
	}
}

function compare(a,b)
 	return a[1] < b[1]
end


-- Fonction d'enregistrement des donnees extraites dans la BD
function registerindb(seq, filename)
	pseudoTab = tagstring(seq, "#pseudo")
	if(pseudoTab ~= nil and #pseudoTab ~= 0) then
		pseudo = pseudoTab[1]
		
		-- Nom principal du player
		db["players"][pseudo] = {}
		db["players"][pseudo]["pseudo"] = pseudoTab
		
		dataAjoute = dataAjoute + 1

		-- Mains
		local mains = tagstring(seq, "#main")
		db["players"][pseudo]["mains"] = {}
		if(mains ~= nil) then
			db["players"][pseudo]["mains"] = mains
			dataAjoute = dataAjoute + #mains
		end
		
		-- Nationalite
		local nationality = tagstring(seq, "#nationality")
		db["players"][pseudo]["nationality"] = {}
		if(nationality ~= nil) then
			db["players"][pseudo]["nationality"] = nationality
			dataAjoute = dataAjoute + #nationality
		end
		
		
		-- Nicknames
		local nicknames = tagstring(seq, "#nickname")
		db["players"][pseudo]["nicknames"] = {}
		if(nicknames ~= nil) then
			db["players"][pseudo]["nicknames"] = nicknames
			dataAjoute = dataAjoute + #nicknames
		end
		

		-- Ranks
		local rank = tagstringlink(seq, "#globalRank", "#rank")
		db["players"][pseudo]["globalRank"] = {}
		if(rank ~= nil) then
			db["players"][pseudo]["globalRank"] = rank
			dataAjoute = dataAjoute + #rank
		end

		-- Fichier
		db["players"][pseudo]["article"] = filename

		db["players"][pseudo]["sponsors"] = {}
		db["players"][pseudo]["money"] = {}
		db["players"][pseudo]["birth"] = {}
		db["players"][pseudo]["birth"]["day"] = {}
		db["players"][pseudo]["birth"]["month"] = {}
		db["players"][pseudo]["birth"]["year"] = {}
		db["players"][pseudo]["birth"]["age"] = {}

		count = count + 1
	end
end



-- Permet d'extraire des sequences de dark les mots detectes
function tagstring (seq, tag, deb, fin)
	-- Valeurs par défauts pour les paramètres
	deb, fin = deb or 1, fin or #seq
	local tab = {}
	local isRedundant = false
	
	for idx, pos in ipairs(seq[tag]) do
		local d, f = pos[1], pos[2]
		isRedundant = false
		if d >= deb and f <= fin then
			local res = ""
			for i = d, f do
				if res == "" then
					res = seq[i].token
				else
					res = res .. " " .. seq[i].token
				end
			end
			for index, val in ipairs(tab) do
				if string.match(res, val) then
					isRedundant = true
					break
				end
			end
			if not isRedundant then
				tab[#tab + 1] = res
			end
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
-- Supprime les doublons du tableau en entrée
--function remove_duplicates (tab)
--	for idx, pos in ipairs(tab) do
--	return tab
--end 

-- ***************************************** --


-- *********** Partie Extraction *********** --

-- Sequence pour eviter les notations de type "[12]"
local escapeBalise = '("[" /^[0-9]+$/ "]")?'

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
P:pattern([[ [#pseudo_ ((#w /^[.-]$/ (#w|#d)) | (#w{1,2}))]  ("(".{0,30}? ")" | /^[^.]+$/{0,30}?)?  is (#w)*  ( smasher | Melee player | SSBM | main) ]])
P:pattern([[ [#joueur [#pseudo #pseudo_] /^[^.]+$/{0,80}? (#character | #globalRank) ] ]])

P:pattern([[ from[#nationality (#W{0,3}?","(#W{1,3}?) | #W{0,3})] (who|and) ]])
P:pattern([[ #pseudo (#w | "," | "(" | ")"){0,20}? from[#nationality (#W{0,3}?","(#W{1,3}?) | #W{0,3})] (who|and|",") ]])

-- Detection des mains
P:pattern([[  [#main #character] (("," [#main #character])*? and [#main #character])? main]])
P:pattern([[ (mains | main) [#main #character] (("," [#main #character])*? and [#main #character])? ]])
P:pattern([[ (mains | main) [#main #character] ("/" [#main #character])+ ]])
P:pattern([[ best Melee? [#main #character] ]])

-- Detection des surnoms du joueur (a completer) (?)
P:pattern([[ (also known as (simply)?| aka | also referred to as (just)?) (( [#nickname ( #w | #W ){1,5}] ( and | "," | or){0,2} ){1,10}? ( is | "." | ")"))? ]])

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
	["#pseudo_"] = "red",
	["#joueur"] = "yellow",
	["#nationality"] = "green",
	["#main"] = "blue",
	["#nickname"] = "green",
	["#year"] = "yellow",
	["#tournoi"] = "yellow",
	["#rank"] = "green",
	["#globalRank"] = "green",
}

local rep = "../Smashers"
for fichier in os.dir(rep) do
	for line in io.lines(rep.."/"..fichier) do
		line = line:gsub("%[[0-9]+%]", "")
		line = line:gsub("%p", " %0 ")
		seq = dark.sequence(line)
		P(seq)
		-- print(seq:tostring(tags))
		-- print("\n")
		--Ajout des infos dans la bd
		registerindb(seq, fichier)
	end
end

local keys = {}
for key in pairs(db["players"]) do 
	table.insert(keys, key) 
end
table.sort(keys)

-- Ecriture dans un fichier de toutes les informations
file = io.open("DbbContextFirst.txt", "w")
file:write("return {\n\tplayers = {")
for v, key in ipairs(keys) do 
	file:write("\t\n\t\t[\"" .. key .. "\"] = ")
	local tempStr = serialize(db["players"][key])
	tempStr = tempStr:gsub("\n", "\n\t\t")
	file:write(tempStr .. ",")
end
file:write("\n\t},\n}")
io.close(file)

print("Nombre de players : " .. count)
print("Nombre de données dans la base de donnée en non structuré : " .. dataAjoute)


