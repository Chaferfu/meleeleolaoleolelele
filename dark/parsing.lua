local dark = require("dark")

local function preprocessing(seq)
	--TODO : Séparer la ponctuation des mots (.,; etc.) et les espaces/sauts de ligne/tabulations superflues
	end

local P = dark.pipeline()
seq = dark.sequence("Armada is a smasher from Sweden who mains Peach and Fox in Melee . Ken Hoang , also referred to as just Ken , SephirothKen , or The King of Smash , is an American professional smasher of Vietnamese descent who mains Marth , ever since his debut in Tournament Go 4 .")

P:basic()
P:lexicon("#character", "lexicon/ssbm_characters.txt");
P:pattern([[ [#pseudo .] is /[^.]*/  smasher]])
P(seq)


local tags = {
	["#character"] = "blue",
	["#player"] = "green",
	["#pseudo"] = "red"
}

print(seq:tostring(tags))

