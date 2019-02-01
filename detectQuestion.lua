dark = require("dark")

local main = dark.pipeline()

local basic = dark.basic()

main:model("model/postag-en")
main:lexicon("#character", "./lexique/ssbm_characters.txt")
main:lexicon("#player", "./lexique/ssbm_players.txt")

local tags = {
	["#character"] = "red",
	["#player"] = "blue",
}



--LECTURE DU FICHIER 

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
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
  line = line:gsub("%p", " %0 ")
  print('line[' .. k .. ']', main(line):tostring(tags))
end