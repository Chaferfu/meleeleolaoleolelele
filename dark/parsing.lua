local dark = require("dark")

local function preprocessing(seq)
	--TODO : Séparer la ponctuation des mots (.,; etc.) et les espaces/sauts de ligne/tabulations superflues
	end

local P = dark.pipeline()
--[[seq = dark.sequence("Armada is a smasher from Sweden who mains Peach , Fox , Jigglypuff and Dr. Mario in Melee .")
seq2 = dark.sequence("Ken Hoang , also referred to as just Ken , SephirothKen , or The King of Smash , is an American professional smasher of Vietnamese descent who mains Marth , ever since his debut in Tournament Go 4 .")
seq3 = dark.sequence("FatGoku is a smasher from Oregon who is one of the top competitors in the Oregon/Pacific Northwest area.")
seq4 = dark.sequence("Boyd is a Melee Ice Climbers , Fox , Falco and Mario main from Northeastern Ohio .")
--]]
P:basic()
P:lexicon("#character", "lexicon/ssbm_characters.txt")
P:pattern([[ [#pseudo .]  ("(".{0,30}? ")" | .{0,30}?)  is ([#nationality #W] | #w)*  ( smasher | Melee player )]])
P:pattern([[ [#joueur #pseudo (#w | "," | "(" | ")"){0,40}? #character] ]])
P:pattern([[ #pseudo (#w | "," | "(" | ")"){0,20}? fros[#nationality #W] ]])
P:pattern([[ from [#nationality #W] ]])

-- Detection des mains
P:pattern([[ [#main #character] (("," [#main #character])*? and [#main #character])? main]])
P:pattern([[ mains [#main #character] (("," [#main #character])*? and [#main #character])? ]])




local tags = {
	["#character"] = "blue",
	["#player"] = "green",
	["#pseudo"] = "yellow",
	["#joueur"] = "yellow",
	["#nationality"] = "green",
	["#main"] = "blue"
}

local rep = "../WikiSmash"
for fichier in os.dir(rep) do
	for line in io.lines(rep.."/"..fichier) do
		line = line:gsub("%p", " %0 ")
		seq = dark.sequence(line)
		P(seq)
		print(seq:tostring(tags))
		print("\n")
	end
end

--[[print(seq:tostring(tags))
print("\n")

P(seq2)
print(seq2:tostring(tags))
print("\n")

P(seq3)
print(seq3:tostring(tags))
print("\n")

P(seq4)
print(seq4:tostring(tags))
print("\n")
--]]
