dark = require("dark")


--- historique questions = liste de tags

historiqueQuestion = {}
--- historique réponse = lié à question précedente et liste des réponses.

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

db.players.leffen = db.players.Leffen

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

-- Returns the Levenshtein distance between the two given strings
function string.levenshtein(str1, str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local matrix = {}
	local cost = 0
	
        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
	
        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (str1:byte(i) == str2:byte(j)) then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

local main = dark.pipeline()
local applyLexicons = dark.pipeline()

main:basic()


-- main:model("model-2.3.0/postag-en")
main:lexicon("#character", load_nocase("./lexique/ssbm_characters.txt"))
main:lexicon("#player", load_nocase("./lexique/ssbm_players.txt"))
main:lexicon("#questionWord", "./lexique/question_words.txt")
main:lexicon("#tournament", load_nocase("./lexique/lexique_tournois.txt"))
main:pattern([[

	[#playerCharacterQuestion
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

main:pattern([[

	[#tournamentPlayerQuestion
		(/[Ww]hich/ | /[Ww]hat/) ("player" | "players") (#w | #p){0,10}? #tournament (#w | #p){0,10}? "?"?
	]

]])


applyLexicons:lexicon("#character", load_nocase("./lexique/ssbm_characters.txt"))
applyLexicons:lexicon("#player", load_nocase("./lexique/ssbm_players.txt"))
applyLexicons:lexicon("#questionWord", "./lexique/question_words.txt")
applyLexicons:lexicon("#tournament", load_nocase("./lexique/lexique_tournois.txt"))

local tags = {
	-- ["#tournament"] = "red",
	["#playerInfoQuestion"] = "blue",
	["#playerCharacterQuestion"] = "red",
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

function extractTag(seq, tag)
	index = seq[tag]
	toReturn = {}
	for i, emplacement in pairs(index) do
		toReturn[#toReturn + 1] = seq[emplacement[1]]
	end

	return toReturn
end

function handleQuestion(question)
	question = dark.sequence(question:gsub("%p", " %0 "))

	for i = 1, #question do
		print(question[i].token )
		for kw in io.lines("lexique/ssbm_characters.txt") do
			if question[i].token ~= kw and question[i].token ~= kw:lower() and (string.levenshtein(question[i].token, kw:lower()) == 1 or string.levenshtein(question[i].token, kw) == 1) and string.len(question[i].token) > 2 then
				print("Did you mean " .. kw .. " ?")
				return
			end
		end
	end
		
	main(question)
	print("question : " .. question:tostring())

	if havetag(question, "#playerInfoQuestion") then
<<<<<<< HEAD

		
		--[[print(serialize(question["#player"]))
		print("on est là")
--]]	player = extractTag(question, "#player")[1].token
		historiqueQuestion["#playerInfoQuestion"] = {player}
		playerInfo = db.players[player]
=======
		handlePlayerInfoQuestion(question)
		table.insert(historiqueQuestion, "#playerInfoQuestion")
	end
>>>>>>> 1d044838840de0cd25b7dde91f84bb547e10344e


	if havetag(question, "#playerCharacterQuestion") then
		handleplayerCharacterQuestion(question)
	end
end

function handleplayerCharacterQuestion(question)

	player = extractTag(question, "#player")[1].token
	playerInfo = db.players[player]

	playerMains = ""

	print()
	for i = 1, #db.players[player].main do 
		if i == 1 then 
			playerMains = playerMains .. db.players[player].main[i]
		else
			playerMains =  playerMains .. ", " .. db.players[player].main[i] 
		end
	end

	print(player .. " plays " .. playerMains .. ".")
end


function handlePlayerInfoQuestion(question)

	player = extractTag(question, "#player")[1].token
	playerInfo = db.players[player]

	playerMains = ""

	for k,v in pairs(db.players[player].main) do 
		playerMains = playerMains .. v .. ", "
	end

	print(player .. " is a player from " .. playerInfo.nationality .. " who mains " .. playerMains .. " and is currently ranked " .. playerInfo.rank .. "th on the MPGR ladder.")

end









----------------------------------Display lines ---------------------------------------------

-- print all line numbers and their contents
--dark.sequence() ?

--[[for k,line in pairs(lines) do
  print('line[' .. k .. ']', (main(line)):tostring(tags))
end--]]

function principale()
	print("----- Welcome to meleeleolaoleolelele -----")
	print()
	print("meleeleolaoleolelele : Hey ! Do you have a question regarding Super Smash Bros. Melee ?")
	repeat
		print()
		io.write("You:")
		question = io.read()
		handleQuestion(question)
		print(serialize(historiqueQuestion))
	until question == "q"
end

principale()
