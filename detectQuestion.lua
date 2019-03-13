dark = require("dark")

debug = false
useDB = true

quesionTags = {"#playerCharacterQuestion"
	,"#playerInfoQuestion"
	,"#playerNationalityQuestion"
	,"#tournamentInfoQuestion"
	,"#tournamentPlayerQuestion",
	}


--- historique questions = liste de tags
historiqueQuestion = {}
--- historique réponse = lié à question précedente et liste des réponses.

db = {}
db.players = {}
db.players["Armada"] = {

	mains = {"Peach", "Fox"},
	nationality = {"Sweden"},
	globalRank = {3},

}
db.players["Mango"] = {

	mains = {"Falco", "Fox"},
	nationality = {"US"},
	globalRank = {6}

}
db.players["Leffen"] = {

	mains = {"Fox"},
	nationality = {"Sweden"},
	globalRank = {4}

}

db.players["Zain"] = {

	mains = {"Marth"},
	nationality = "US",
	globalRank = {1},

}

db.tournaments = {}

db.tournaments["Genesis 3"] = {
	players = {{player = "Leffen", rank = 1}, {player = "Armada", rank = 2}},                                                                                                       
	year = "2012"
}

db.players.leffen = db.players.Leffen
db.players.armada = db.players.Armada
db.players.mango = db.players.Mango

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
main:lexicon("#questionWord", load_nocase("./lexique/question_words.txt"))
main:lexicon("#tournament", load_nocase("./lexique/lexique_tournois.txt"))
main:lexicon("#bye", load_nocase("./lexique/bye.txt"))

main:pattern([[

	[#playerCharacterQuestion
			#questionWord (#w | #p){0,10}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,5}? (character | main | Character | Main | play | Play) "?"{0,1}
	]

]])
main:pattern([[
	[#playerInfoQuestion
		(/[Ww]ho/ "is" | /[Ww]ho/ "'" "s") (#w | #p){0,10}?  (#player|"he"|"she") "?"?
	]

]])

main:pattern([[

	[#playerNationalityQuestion
		/[Ww]hat/ (#w | #p){0,10}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,10}? (/[Nn]ationality/ | country)
	]

]])

main:pattern([[

	[#playerNationalityQuestion
		/[Ww]here/ (#w | #p){0,10}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,10}? (live | from)
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

	[#tournamentEntrantsQuestion
		/[Ww]ho/ (#w | #p){0,10}? #tournament "?"?
	]

]])

main:pattern([[

	[#tournamentEntrantsQuestion
		(/[Ww]hich/ | /[Ww]hat/) ("player" | "players") (#w | #p){0,10}? #tournament (#w | #p){0,10}? "?"?
	]

]])

main:pattern([[

	[#linkToPrevious
		/[Ww]hat/ (#w | #p){1}? #player  "?"
	]

]])

main:pattern([[

	[#linkToPrevious
		/[Aa]nd/ #player "?"?
	]

]])


main:pattern([[

	[#playerNicknameQuestion

		/[Ww]hat/ (#w | #p){0,5}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,5}? (/[Nn]ickname/ | "nicknames" | "called" | /[Nn]ick/ | nicks ) "?"?

	]

]])

main:pattern([[

	[#playerRankQuestion

		/[Ww]hat/ (#w | #p){0,5}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,5}? ("rank" | "ranked") "?"?

	]

]])

main:pattern([[

	[#characterQuestion

		/[Ww]ho/ (#w | #p){0,10}? (#character|"him"|"her"|"it") "?"?

	]

]])

main:pattern([[

	[#comparaisonQuestion

		(/[Ww]ho/ "is" | /[Ww]ho/ "'" "s") (#w | #p){0,10}? ("best" | "better") "between" "?"?

	]

]])

main:pattern([[

	[#comparaisonQuestion

		(/[Ww]ho/ "is" | /[Ww]ho/ "'" "s") (#w | #p){0,10}? "best" "between" #player "and" #player "?"?

	]

]])

main:pattern([[

	[#bestPlayerQuestion
		(/[Ww]ho/ "is" | /[Ww]ho/ "'" "s") (#w | #p){0,5}? "best" "?"?
	]

]])


main:pattern([[

	[#birthPlayerQuestion
		#questionWord  (#w | #p){0,5}? (#player | "his" | "him" | "he" | "her" | "she")  (#w | #p){0,5}? ("birthday" | "bday" | "anniversary") "?"?
	]

]])

main:pattern([[

	[#birthPlayerQuestion
		/[Ww]hen/  (#w | #p){0,5}? (#player | "his" | "him" | "he" | "her" | "she")  (#w | #p){0,5}? "born" "?"?
	]

]])


main:pattern([[

	[#playerSponsorQuestion
			#questionWord (#w | #p){0,10}? (#player | "his" | "him" | "he" | "her" | "she") (#w | #p){0,5}? (organisation | sponsor | team) "?"?
	]

]])




-- main:pattern([[

-- 	[#implicitMainQuestion
-- 		/[Hh]is/ (main | mains | character | characters) "?"
-- 	]

-- ]])

applyLexicons:lexicon("#character", load_nocase("./lexique/ssbm_characters.txt"))
applyLexicons:lexicon("#player", load_nocase("./lexique/ssbm_players.txt"))
applyLexicons:lexicon("#questionWord", "./lexique/question_words.txt")
applyLexicons:lexicon("#tournament", load_nocase("./lexique/lexique_tournois.txt"))

local tags = {
	["#bestPlayerQuestion"] = "red",
	["#playerNicknameQuestion"] = "blue",
	["#characterQuestion"] = "green",
	-- ["#tournamentInfoQuestion"] = "green",
	-- ["#tournamentDateQuestion"] = "yellow",
	-- ["#tournamentPlayerQuestion"] = "cyan",
	-- ["#playerNationalityQuestion"] = "magenta"

	
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
	if debug and #seq[tag] ~= 0 then print("Question is : " .. tag) end
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
















--------------------------------QUESTION HANDLING--------------------------------------------------------------


function handleQuestion(question)
	questionLevenstein = {}
	questionLevenstein2 = {}
	tomodify = {}
	question2 = question:gsub("%p", " %0 ")
	for word in question2:gmatch("%S+") do table.insert(questionLevenstein, word) end
	question = dark.sequence(question:gsub("%p", " %0 "))
	
		
	main(question)
	---print(#question)
	---print(#questionLevenstein)

	----- here : levenshtein ------------
	
	if(not havetag(question, "#playerCharacterQuestion") and not havetag(question, "#playerNationalityQuestion") or (havetag(question, "#player") and not havetag(question,"#playerNicknameQuestion"))) then
			
		for i = 1, #question do
			if debug then 
				print(question[i].token)
			end
			tomodify[i] = false
			for kw in io.lines("lexique/ssbm_players.txt") do
				kw = kw:gsub('\r\n?', '')
				if question[i].token ~= kw and question[i].token ~= kw:lower() and question[i].token ~= "are" and question[i].token ~= "main" and (string.levenshtein(question[i].token, kw:lower()) == 1 or string.levenshtein(question[i].token, kw) == 1) and string.len(question[i].token) > 2 then
	
					print("Did you mean " .. kw .. " ?")
					io.write("You : ")
					answer = io.read()
					if(answer == "yes" or answer == "Yes" or answer == "yeah" or answer == "Yeah") then

						tomodify[i] = true
						table.insert(questionLevenstein2, i, kw)
						

					else
						print("Ok...")
					end
				end
			end
			if(tomodify[i] == false) then
				table.insert(questionLevenstein2, i, questionLevenstein[i])
			end
		end
		questionLevenstein2 = dark.sequence(questionLevenstein2)
		main(questionLevenstein2)
		question = questionLevenstein2
	end





	---------------------------------




	

	

	if havetag(question, "#bye") then
		handleBye()

	elseif havetag(question, "#playerCharacterQuestion") then
		handleplayerCharacterQuestion(question)
	elseif havetag(question, "#comparaisonQuestion") then
		handleComparaisonQuestion(question)

	elseif havetag(question, "#playerInfoQuestion") then
		
		handlePlayerInfoQuestion(question)	

	elseif havetag(question, "#playerNationalityQuestion") then
		handlePlayerNationalityQuestion(question)

	elseif havetag(question, "#characterQuestion") then
		handleCharacterQuestion(question)

	elseif havetag(question, "#playerRankQuestion") then 
		handlePlayerRankQuestion(question) 

	elseif havetag(question, "#bestPlayerQuestion") then 
		handleBestPlayerQuestion(question)
	elseif havetag(question, "#playerNicknameQuestion") then 
		handlePlayerNicknameQuestion(question) 
	elseif havetag(question, "#birthPlayerQuestion") then 
		handleBirthPlayerQuestion(question) 
	elseif havetag(question, "#playerSponsorQuestion") then 
		handlePlayerSponsorQuestion(question) 

	elseif havetag(question, "#linkToPrevious") then
		handlePreviousQuestion(question)

	


	-- elseif havetag(question, "#implicitMainQuestion")then 
	-- 	handleImplicitMainQuestion(question)

	else

		botSays(incomprehension[ math.random( #incomprehension ) ])

	end
end

-- function handleImplicitMainQuestion(question)
	

function handleBye()
	botSays(byeSentences[ math.random( #byeSentences ) ], nil, true)
	print("meleeleolaoleolelele left the chat")
	terminate = true
end

function handleBirthPlayerQuestion( question )

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")
			return
		end
	end
	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerRankQuesion", player, sayOrShutUp(db.players[player].globalRank)}

	if db.players[player].birth == nil then 
		botSays("I don't know when " .. player .. "is born.", player) 
		return
	end

	botSays(player .. " is born on the " .. sayOrShutUp(db.players[player].birth.day[1]) .. "/"  .. sayOrShutUp(db.players[player].birth.month[1]) .. "/"  .. sayOrShutUp(db.players[player].birth.year[1]) .. ".")
end

function handleBirthPlayerQuestion( question )

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")
			return
		end
	end
	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	historiqueQuestion[#historiqueQuestion + 1] = {"#birthPlayerQuestion", player, sayOrShutUp(db.players[player].globalRank)}

	if debug then print(serialize(db.players[player].birth)) end

	if db.players[player].birth.day == nil then
		botSays("I don't know when " .. player .. " is born.", player)
		return
	end


	botSays(player .. " is born on the " .. sayOrShutUp(db.players[player].birth.day) .. " / "  .. sayOrShutUp(db.players[player].birth.month) .. " / "  .. sayOrShutUp(db.players[player].birth.year) .. ".") 
end

function handlePlayerSponsorQuestion(question)
	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")
			return
		end
	end
	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerSponsorQuestion", player, sayOrShutUp(db.players[player].globalRank)}

	if db.players[player].sponsors == nil or db.players[player].sponsors[1] == nil then
		botSays("I don't know what is " .. player .. "'s sponsor.", player) 
		return
	end

	botSays(player .. "'s sponsor is  " .. db.players[player].sponsors[1] .. ".", player)
end

function getBestPlayer()

	for k,v in pairs(db.players) do
		if debug then print("player is ".. k) end
		if v.globalRank ~= nil and tonumber(v.globalRank[1]) == 1 then 
			return k
		end
	end
	return nil

end

function handleBestPlayerQuestion(question)
	player = getBestPlayer()

	if player ~= nil then
		botSays("The best player in the world is currently " .. player .. ".", player)
	else
		botSays("I actually don't know who the best player is haha can you believe that.")
	end
end

function handleCharacterQuestion(question)
	
	if havetag(question, "#character") then 
		character = extractTag(question, "#character")[1].token
	else
		if #historiqueQuestion ~= 0 then
			character = historiqueQuestion[#historiqueQuestion][3]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")

			return
		end
	end

	player = getPlayerWhoPlays(character)

	historiqueQuestion[#historiqueQuestion + 1] = {"#characterQuestion", player, character}

	if player == nil then botSays("hmmm I didn't find anybody who plays ".. character .. " but I must miss something ...")
	else botSays(player .. " plays " .. character .. ".", player) end
end

function getPlayerWhoPlays(character)
	for k,v in pairs(db.players) do
		if debug then print("player is ".. k) end
		for cle, valeur in pairs(v.mains) do
			if debug then 
				print("valeur " .. valeur)
				print("char " .. character)
			end
			if valeur:find(character) or valeur:lower():find(character) then
				return k
			end
		end
	end
	return nil
end

function handleComparaisonQuestion(question)
	if (#historiqueQuestion == 0 and not havetag(question, "#player")) then
		botSays("I don't know who you are talking about...")
	elseif((#historiqueQuestion == 1 and not havetag(question, "#player")) or (#historiqueQuestion > 1 and historiqueQuestion[#historiqueQuestion - 1][2] == historiqueQuestion[#historiqueQuestion][2] and not havetag(question, "#player")) or #extractTag(question, "#player") == 1) then
		
		if #extractTag(question, "#player") == 1 then
			player = extractTag(question, "#player")[1].token
		else
			player = historiqueQuestion[#historiqueQuestion][2]
		end
		if db.players[player] == nil then
			botSays("I don't know " .. player .. ".")
			return
		end
		
		print("I'm sorry, who do I compare him with ?")
		historiqueQuestion[#historiqueQuestion + 1] = {"#comparaisonQuestion", player, db.players[player].globalRank[1]}
		io.write("You : ")
		player2 = io.read()
		newQuestion = "Who ".. "is ".."the ".."best " .."between "..  player .. " and " .. player2 .. " ?"
		handleQuestion(newQuestion)
	elseif(#historiqueQuestion >= 2 and not havetag(question, "#player")) then
		player = historiqueQuestion[#historiqueQuestion - 1][2]
		player2 = historiqueQuestion[#historiqueQuestion][2]
		historiqueQuestion[#historiqueQuestion + 1] = {"#comparaisonQuestion", player, db.players[player].globalRank[1]}
		if (db.players[player2].globalRank[1] < db.players[player].globalRank[1]) then
			botSays(player2 .. " is better than ".. player .. ", his rank is " .. sayOrShutUp(db.players[player2].globalRank) .. " whereas " .. player .. " is ranked " .. sayOrShutUp(db.players[player].globalRank) .. ".", player)
		elseif(db.players[player2].globalRank[1] > db.players[player].globalRank[1]) then
			botSays(player .. " is better than ".. player2 .. ", his rank is " .. sayOrShutUp(db.players[player].globalRank) .. " whereas " .. player2 .. " is ranked " .. sayOrShutUp(db.players[player2].globalRank) .. ".", player)
		else
			botSays("They are pretty much equal, I would even say that they are the same.")
		end

	else
		player = extractTag(question, "#player")[1].token
		player2 =  extractTag(question, "#player")[2].token

		if db.players[player] == nil then
			botSays("I don't know " .. player .. ".")
			return
		end
		if db.players[player2] == nil then
			botSays("I don't know " .. player2 .. ".")
			return
		end
		historiqueQuestion[#historiqueQuestion + 1] = {"#comparaisonQuestion", player, db.players[player].globalRank[1]}
		if (db.players[player2].globalRank[1] < db.players[player].globalRank[1]) then
			botSays(player2 .. " is better than ".. player .. ", his rank is " .. sayOrShutUp(db.players[player2].globalRank) .. " whereas " .. player .. " is ranked " .. sayOrShutUp(db.players[player].globalRank) .. ".", player)
		elseif(db.players[player2].globalRank[1] > db.players[player].globalRank[1]) then
			botSays(player .. " is better than ".. player2 .. ", his rank is " .. sayOrShutUp(db.players[player].globalRank) .. " whereas " .. player2 .. " is ranked " .. sayOrShutUp(db.players[player2].globalRank) .. ".", player)
		else
			botSays("They are pretty much equal, I would even say that they are the same.")
		end
	end
end



function handlePreviousQuestion(question)
	if (#historiqueQuestion == 0) then
		botSays(incomprehension[ math.random( #incomprehension ) ])
	else
		if (historiqueQuestion[#historiqueQuestion][1] == "#playerInfoQuestion") then
			handlePlayerInfoQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#playerCharacterQuestion") then
			handleplayerCharacterQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#playerNationalityQuestion") then
			handlePlayerNationalityQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#playerRankQuesion") then
			handlePlayerRankQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#playerNicknameQuestion") then
			handlePlayerNicknameQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#comparaisonQuestion") then
			handleComparaisonQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#birthPlayerQuestion") then
			handleBirthPlayerQuestion(question)
		elseif(historiqueQuestion[#historiqueQuestion][1] == "#playerSponsorQuestion") then
			handlePlayerSponsorQuestion(question)

			
	
		end
		
	end

end

function handlePlayerNationalityQuestion(question)

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")

			return
		end
	end
	nationality = sayOrShutUp(db.players[player].nationality)
	botSays(player .. " comes from " .. nationality .. ".", player)

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerNationalityQuestion", player, db.players[player].nationality[1]}
end

function handlePlayerRankQuestion(question) 
	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")
			return
		end
	end
	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end
	historiqueQuestion[#historiqueQuestion + 1] = {"#playerRankQuesion", player, sayOrShutUp(db.players[player].globalRank)}

	botSays(player .. " is currently ranked " .. sayOrShutUp(db.players[player].globalRank) .. " on the MPGR ladder")
end 

function handleplayerCharacterQuestion(question)

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")

			return
		end
	end

	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	playerInfo = db.players[player]

	playerMains = ""

	if db.players[player].mains == nil then
		botSays("I don't know what " .. player .. " plays.", player)
		return
	end
		
	for i = 1, #db.players[player].mains do 
		if i == 1 then 
			playerMains = playerMains .. db.players[player].mains[i]
		else
			playerMains =  playerMains .. ", " .. db.players[player].mains[i] 
		end
	end

	

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerCharacterQuestion", player, db.players[player].mains[1]}

	botSays(player .. " plays " .. playerMains .. ".", player)
end

function handlePlayerNicknameQuestion(question)

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")
			return
		end
	end

	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	playerInfo = db.players[player]

	playerNicknames = ""
	if db.players[player].nicknames ~= nil and #db.players[player].nicknames ~= 0 then 
		for i = 1, #db.players[player].nicknames do 
			if i == 1 then 
				playerNicknames = playerNicknames .. db.players[player].nicknames[i]
			else
				playerNicknames =  playerNicknames .. ", " .. db.players[player].nicknames[i] 
			end
		end
	else
		botSays("To my knowledge, " .. player .. " does not have any nicknames.", player)
		return
	end

	

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerNicknameQuestion", player, db.players[player].nicknames}

	botSays(player .. " is also called " .. playerNicknames .. ".", player)
end


function handlePlayerInfoQuestion(question)

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			botSays("I didn't understand who you are talking about.")

			return
		end
	end
	historiqueQuestion[#historiqueQuestion + 1] = {"#playerInfoQuestion", player}
	playerInfo = db.players[player]

	playerMains = ""

	if db.players[player] == nil then
		botSays("I don't know " .. player .. ".")
		return
	end

	if db.players[player].mains ~= nil then
		for i = 1, #db.players[player].mains do 
			if i == 1 then 
				playerMains = playerMains .. db.players[player].mains[i]
			else
				playerMains =  playerMains .. ", " .. db.players[player].mains[i] 
			end
		end
	end


	botSays(player .. " is a player from " .. sayOrShutUp(playerInfo.nationality) .. " who mains " .. (playerMains) .. " and is currently ranked " .. sayOrShutUp(playerInfo.globalRank) .. " on the MPGR ladder.", player)

end


function sayOrShutUp(thing)
	if thing ~= nil then
		return thing[1]
	else
		return "... well i don't know"
	end
end










----------------------------------Display lines ---------------------------------------------


if debug then
	for k,line in pairs(lines) do
	print('line[' .. k .. ']', (main(line)):tostring(tags))
	end
end

function botSays(answer, subject, no_followup)
	
	subject = subject or nil
	no_followup = no_followup or nil

	if debug then 
		if subject ~= nil then 
			print("subject : " .. subject) 
		else 
			print("subject is nil") 
		end

		-- print("answer " .. answer)

	end

	if no_followup == true then 
		print("meleeleolaoleolelele : " .. answer)



	elseif subject == nil then 
		print("meleeleolaoleolelele : " .. answer .. " " .. otherQuestion[ math.random( #otherQuestion ) ])

	else 
		print("meleeleolaoleolelele : " .. answer .. " " .. questionAbout[ math.random( #questionAbout ) ] .. subject .. "?")
	end
end

function principale()


	terminate = false

	if useDB then
		db = dofile("file2.txt")

		--gere des problemes de minuscules
		for k,v in pairs(db.players) do
			db.players[k:lower()] = db.players[k]
		end
	end

	byeSentences = {}
	for line in io.lines("repliques/bye.txt") do
		byeSentences[#byeSentences + 1] = line
	end

	questionAbout = {}
	for line in io.lines("repliques/questionAbout.txt") do
		questionAbout[#questionAbout + 1] = line
	end

	incomprehension = {}
	for line in io.lines("repliques/incomprehension.txt") do
		incomprehension[#incomprehension + 1] = line
	end

	otherQuestion = {}
	for line in io.lines("repliques/otherQuestion.txt") do
		otherQuestion[#otherQuestion + 1] = line
	end


	print("----- Welcome to meleeleolaoleolelele -----")
	print()
	print("meleeleolaoleolelele : Hey ! Do you have a question regarding Super Smash Bros. Melee ?")
	io.write("You : ")
		question = io.read()
		if string.match( question,"yes" ) or string.match( question,"Yes" ) then 
			botSays("Well go ahead and ask me my dude !")
		else	
			handleQuestion(question)
		end
		if debug then 
			print(serialize(historiqueQuestion))
		end

	repeat
		io.write("You : ")
		question = io.read()
		handleQuestion(question)
		if debug then 
			print(serialize(historiqueQuestion))
		end
	until terminate == true
end

principale()


