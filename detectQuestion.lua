dark = require("dark")

debug = false

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
		(/[Ww]ho/ "is" | /[Ww]ho/ "'" "s") (#w | #p){0,10}?  #player "?"?
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
		/[Aa]nd/ #player "?"
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
















--------------------------------QUESTION HANDLING--------------------------------------------------------------


function handleQuestion(question)
	question = dark.sequence(question:gsub("%p", " %0 "))

		
	main(question)


	----- here : levenshtein ------------
	for i = 1, #question do
		if debug then 
			print(question[i].token )
		end
		for kw in io.lines("lexique/ssbm_characters.txt") do
			if question[i].token ~= kw and question[i].token ~= kw:lower() and (string.levenshtein(question[i].token, kw:lower()) == 1 or string.levenshtein(question[i].token, kw) == 1) and string.len(question[i].token) > 2 then
				print("Did you mean " .. kw .. " ?")
				return
			end
		end
	end


--if noTag(question) then
----for kw in io.lines("lexique/ssbm_players.txt") do
------if question[i].token ~= kw and question[i].token ~= kw:lower() and (string.levenshtein(question[i].token, kw:lower()) == 1 or string.levenshtein(question[i].token, kw) == 1) and string.len(question[i].token) > 2 then
--------question[i].token = kw
------end
----end
----main(question)
--end




	---------------------------------







	if debug then 
		print("question : " .. question:tostring())
		print("\n\n\n")
	end
	

	

	if havetag(question, "#bye") then
		handleBye()

	elseif havetag(question, "#playerCharacterQuestion") then
		handleplayerCharacterQuestion(question)

	elseif havetag(question, "#playerInfoQuestion") then
		--[[print(serialize(question["#player"]))
		print("on est là")
--]]	
		handlePlayerInfoQuestion(question)	

	elseif havetag(question, "#playerNationalityQuestion") then
		handlePlayerNationalityQuestion(question)

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
			return
		end
	end
	nationality = db.players[player].nationality
	botSays(player .. " comes from " .. nationality .. ".", player)

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerNationalityQuestion", player, db.players[player].nationality}
end


function handleplayerCharacterQuestion(question)

	if havetag(question, "#player") then 
		player = extractTag(question, "#player")[1].token
	else
		if #historiqueQuestion ~= 0 then
			player = historiqueQuestion[#historiqueQuestion][2]
		else
			botSays(incomprehension[ math.random( #incomprehension ) ])
			return
		end
	end

	playerInfo = db.players[player]

	playerMains = ""

	for i = 1, #db.players[player].main do 
		if i == 1 then 
			playerMains = playerMains .. db.players[player].main[i]
		else
			playerMains =  playerMains .. ", " .. db.players[player].main[i] 
		end
	end

	historiqueQuestion[#historiqueQuestion + 1] = {"#playerCharacterQuestion", player, db.players[player].main}

	botSays(player .. " plays " .. playerMains .. ".", player)
end


function handlePlayerInfoQuestion(question)

	player = extractTag(question, "#player")[1].token
	historiqueQuestion[#historiqueQuestion + 1] = {"#playerInfoQuestion", player}
	playerInfo = db.players[player]

	playerMains = ""

	for k,v in pairs(db.players[player].main) do 
		playerMains = playerMains .. v .. ", "
	end

	botSays(player .. " is a player from " .. playerInfo.nationality .. " who mains " .. playerMains .. " and is currently ranked " .. playerInfo.rank .. "th on the MPGR ladder.", player)

end



















----------------------------------Display lines ---------------------------------------------

-- print all line numbers and their contents
--dark.sequence() ?

--[[for k,line in pairs(lines) do
  print('line[' .. k .. ']', (main(line)):tostring(tags))
end--]]

function botSays(answer, subject, no_followup)
	
	subject = subject or nil
	no_followup = no_followup or nil

	if debug then 
		if subject ~= nil then 
			print("subject : " .. subject) 
		else 
			print("subject is nil") 
		end

		print("answer " .. answer)
		print(serialize(questionAbout))



		for q, v in ipairs(questionAbout) do
			print("questionAbout " .. v)
		end



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

	if debug then 
		print( serialize(incomprehension))
	end

	print("----- Welcome to meleeleolaoleolelele -----")
	print()
	print("meleeleolaoleolelele : Hey ! Do you have a question regarding Super Smash Bros. Melee ?")
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



--TODO better levensheit (comprende la question raturee)