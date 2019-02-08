local dark = require("dark")

local P = dark.pipeline()

local db = {
	["players"] = {
		
	}, 
	
	["playerInfo"] = {
		
	}
}

--function registerindb (

-- TODO Faire une premiere passe sur TOUS les joueurs pour enregistrer 
-- les pseudo des joueurs independemment un lexique puis faire une 
-- deuxieme passe en utilisant le lexique pour chercher tout le reste

P:basic()
P:lexicon("#character", "lexicon/ssbm_characters.txt")
-- P:lexicon("#pseudo", "lexicon/pseudos.txt")

-- Detection du pseudo du joueur
P:pattern([[ [#pseudo .]  ("(".{0,30}? ")" | .{0,30}?)  is ([#nationality #W] | #w)*  ( smasher | Melee player )]])

P:pattern([[ [#joueur #pseudo (#w | "," | "(" | ")"){0,40}? #character] ]])
P:pattern([[ #pseudo (#w | "," | "(" | ")"){0,20}? from[#nationality #W] ]])
P:pattern([[ from [#nationality #W] ]])

-- Detection des mains
P:pattern([[ [#main #character] (("," [#main #character])*? and [#main #character])? main]])
P:pattern([[ mains [#main #character] (("," [#main #character])*? and [#main #character])? ]])

-- Detection des surnoms du joueur (a completer) (?)
P:pattern([[ (also known as | aka | also referred to as) [#nickname .{1,10}?] ("," [#nickname .{1,10}?]){1,10}? and [#nickame .] ]])

-- Detection des années
P:pattern([[ [#year /^([1-2][0-9][0-9][0-9])$/] ]])

-- Detection des tournois 
P:pattern([[ ( won | winning )  ( [#tournoi .{0,5}?] ( "," | and | ".")){0,5} ]])
P:pattern([[ facing .{0,3}? in .{0,2}? at [#tournoi .{0,5}?] ( "," | "." ) ]])

-- Detection des phrases (attention aux acronymes)
P:pattern([[ [#acronym (/^%u$/ ".")+ /^%u$/ ] ]])
P:pattern([[ [#sentence /^[A-Z]/ (#acronym | .)*? "."] ]])

local tags = {
	["#character"] = "blue",
	["#pseudo"] = "yellow",
	["#joueur"] = "yellow",
	["#nationality"] = "green",
	["#main"] = "blue",
	["#nickname"] = "green",
	["#year"] = "yellow",
	["#tournoi"] = "yellow",
}

seqList = {}
i = 1;

local rep = "../WikiSmash"
for fichier in os.dir(rep) do
	for line in io.lines(rep.."/"..fichier) do
		line = line:gsub("%p", " %0 ")
		seq = dark.sequence(line)
		P(seq)
		print(seq:tostring(tags))
		print("\n")
		seqList[i] = seq
		i = i + 1
	end
end

for i=1, #seqList, 1 do
	print(seqList[i]:tostring(tags))
end
