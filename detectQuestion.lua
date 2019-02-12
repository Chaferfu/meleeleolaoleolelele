dark = require("dark")

db = {}
db.players = {}
db.players["Armada"] = {

	main = {"Peach", "Fox"},
	nationality = "Sweden",
	rank = 3,

}
db.players["Mango"] = {

	main = {"Falco", "Fox"},
	nationality = "US",
	rank = 6

}
db.players["Leffen"] = {

	main = {"Fox"},
	nationality = "Sweden",
	rank = 4

}

db.players["Zain"] = {

	main = {"Marth"},
	nationality = "US",
	rank = 11

}

db.tournaments = {}

db.tournaments["Genesis 3"] = {
	players = {{player = "Leffen", rank = 1}, {player = "Armada", rank = 2}},                                                                                                       
	year = "2012"
}


local function load_nocase(fname)
	local tmp = {}
	for line in io.lines(fname) do
		local nocase = line:lower()
		tmp[#tmp + 1] = line
		if nocase ~= line then
			tmp[#tmp + 1] = nocase
		end
	end
	return tmp
end

local main = dark.pipeline()

main:basic()


--main:model("model-2.3.0/postag-en")
main:lexicon("#character", load_nocase("./lexique/ssbm_characters.txt"))
main:lexicon("#player", "./lexique/ssbm_players.txt")
main:lexicon("#questionWord", "./lexique/question_words.txt")
main:lexicon("#tournament", load_nocase("./lexique/lexique_tournois.txt"))
main:pattern([[

	[#characterQuestion
			#questionWord (#w | #p){0,10}? #player (#w | #p){0,5}? (character | main | Character | Main | play | Play) "?"{0,1}
	]

]])
main:pattern([[
	[#playerInfoQuestion
		("Who" "is" | "Who" "'" "s") (#w | #p){0,10}?  #player "?"
	]

]])

main:pattern([[

	[#playerNationalityQuestion
		/[Ww]hat/ (#w | #p){0,10}? #player (#w | #p){0,10}? (/[Nn]ationality/ | country)
	]

]])

main:pattern([[

	[#playerNationalityQuestion
		/[Ww]here/ (#w | #p){0,10}? #player (#w | #p){0,10}? (live | from)
	]

]])

main:pattern([[

	[#tournamentInfoQuestion
		/[Ww]hat/ "is" #tournament  "?"
	]

]])

main:pattern([[

	[#tournamentDateQuestion
		/[Ww]hen/ (#w | #p){0,10}? #tournament "?"?
	]

]])

main:pattern([[

	[#tournamentPlayerQuestion
		/[Ww]ho/ (#w | #p){0,10}? #tournament "?"?
	]

]])

local tags = {
	--["#character"] = "red",
	["#playerInfoQuestion"] = "blue",
	["#characterQuestion"] = "red",
	["#tournamentInfoQuestion"] = "green",
	["#tournamentDateQuestion"] = "yellow",
	["#tournamentPlayerQuestion"] = "cyan",
	["#playerNationalityQuestion"] = "magenta"

	
}
 


--LECTURE DU FICHIER 

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function havetag(seq, tag)
	return #seq[tag] ~= 0
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = dark.sequence(line:gsub("%p", " %0 "))
  end

  return lines

end

-- tests the functions above
local file = 'questions.txt'
local lines = lines_from(file)














----------------------------------Display lines ---------------------------------------------

-- print all line numbers and their contents
--dark.sequence() ?
for k,line in pairs(lines) do
  print('line[' .. k .. ']', (main(line)):tostring(tags))
end