local dark = require("dark")

-- *************** Partie DB *************** --

local dataAlrdyHere = 0
local dataAdded = 0
local dataModified = 0

db = dofile("DbbContextFirst.txt")

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

-- Fonction d'enregistrement des donnees extraites dans la BD
function registerindb(seq, pseudo)
	if db["players"][pseudo] == nil then
		-- Nom principal du player
		db["players"][pseudo] = {}
		db["players"][pseudo]["mains"] = {}
		db["players"][pseudo]["sponsors"] = {}
		db["players"][pseudo]["globalRank"] = {}
		db["players"][pseudo]["money"] = {}
		db["players"][pseudo]["nationality"] = {}
		db["players"][pseudo]["birth"] = {}
		db["players"][pseudo]["birth"]["day"] = {}
		db["players"][pseudo]["birth"]["month"] = {}
		db["players"][pseudo]["birth"]["year"] = {}
		db["players"][pseudo]["birth"]["age"] = {}
		db["players"][pseudo]["pseudo"] = pseudo
	end
	-- Mains
	local mains = tagstring(seq, "#main")

	for key, value in pairs(mains) do
		local toAdd = true
		for key2, value2 in pairs(db["players"][pseudo]["mains"]) do
			if value == value2 then
				toAdd = false
				dataAlrdyHere = dataAlrdyHere + 1
			end
		end
		if toAdd then
			table.insert(db["players"][pseudo]["mains"], value)
			dataAdded = dataAdded + 1
		end
	end

	-- Sponsors
	local sponsor = tagstring(seq, "#sponsor")
	for key, value in pairs(sponsor) do
		local toAdd = true
		for key2, value2 in pairs(db["players"][pseudo]["sponsors"]) do
			if value == value2 then
				toAdd = false
				dataAlrdyHere = dataAlrdyHere + 1
			end
		end
		if toAdd then
			table.insert(db["players"][pseudo]["sponsors"], value)
			dataAdded = dataAdded + 1
		end
	end

	-- Rank
	local rank = tagstring(seq, "#rank")
	for key, value in pairs(rank) do
		local toAdd = true
		for key2, value2 in pairs(db["players"][pseudo]["globalRank"]) do
			if value == value2 then
				dataAlrdyHere = dataAlrdyHere + 1
				db["players"][pseudo]["globalRank"] = rank
				toAdd = false
			else
				dataAdded = dataAdded + 1
				dataModified = dataModified + 1
				db["players"][pseudo]["globalRank"] = rank
				toAdd = false
			end
		end
		if toAdd then
			db["players"][pseudo]["globalRank"] = rank
			dataAdded = dataAdded + 1
		end
	end

	-- Money
	local money = tagstring(seq, "#money")
	for key, value in pairs(money) do
		local toAdd = true
		for key2, value2 in pairs(db["players"][pseudo]["money"]) do
			if value == value2 then
				dataAlrdyHere = dataAlrdyHere + 1
				db["players"][pseudo]["money"] = money
				toAdd = false
			else
				dataAdded = dataAdded + 1
				dataModified = dataModified + 1
				db["players"][pseudo]["money"] = money
				toAdd = false
			end
		end
		if toAdd then
			db["players"][pseudo]["money"] = money
			dataAdded = dataAdded + 1
		end
	end

	-- Localisation
	local nationality = tagstring(seq, "#nationality")
	for key, value in pairs(nationality) do
		local toAdd = true
		for key2, value2 in pairs(db["players"][pseudo]["nationality"]) do
			if value == value2 then
				dataAlrdyHere = dataAlrdyHere + 1
				db["players"][pseudo]["nationality"] = nationality
				toAdd = false
			else
				dataAdded = dataAdded + 1
				dataModified = dataModified + 1
				db["players"][pseudo]["nationality"] = nationality
				toAdd = false
			end
		end
		if toAdd then
			db["players"][pseudo]["nationality"] = nationality
			dataAdded = dataAdded + 1
		end
	end

	-- Birth
	local birth = tagstring(seq, "#birth")
	if birth ~= nil then
		dataAdded = dataAdded + 1
		local x = tagstringlink(seq, "#birth", "#day")
		if x ~= nil then
			db["players"][pseudo]["birth"]["day"] = x
		end
		x = tagstringlink(seq, "#birth", "#month")
		if x ~= nil then
			db["players"][pseudo]["birth"]["month"] = x
		end
		x = tagstringlink(seq, "#birth", "#year")
		if x ~= nil then
			db["players"][pseudo]["birth"]["year"] = x
		end
		x = tagstringlink(seq, "#birth", "#age")
		if x ~= nil then
			db["players"][pseudo]["birth"]["age"] = x
		end
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


function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
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
P:pattern([[ Smasher ':' [#pseudo #w{1,3}] ]])
P:pattern([[ Melee (main | mains) ([#main #character] ','?)* ]])
P:pattern([[ MPGR ':' [#rank ( /^[0-9]+[tnrs][hdt]$/ )] ]])
P:pattern([[ sponsor '(' s ')' [#sponsor #w{1,3}?] ','? ]])
P:pattern([[ Winnings Super Smash Bros '.' Melee '~' '$' [#money #d] ]])
P:pattern([[ Location [#nationality #W ','? #W?] ]])
P:pattern([[ Birth date [#birth [#month #W] [#day #d] ',' [#year #d] '(' age [#age #d] ')'] ]])

-- ***************************************** --


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

		--Ajout des infos dans la bd
		if(pseudo ~= "" and pseudo ~= nil and #pseudo ~= 0) then
			registerindb(seq, pseudo)
		end
	end
end

-- Ecriture dans un fichier de toutes les informations
file = io.open("DbbContextSecond.txt", "w")
file:write("return")
file:write(serialize(db))
io.close(file)

print("Voici le nombre de données étant similaire en structuré et non structuré : " .. dataAlrdyHere)

print("Voici le nombre de données ajoutée en non structuré : " .. dataAdded)

print("Voici le nombre de données modifié parceque faux ou pas assez précis : " .. dataModified)
