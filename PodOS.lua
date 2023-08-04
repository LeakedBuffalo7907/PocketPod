if periphemu then -- probably on CraftOS-PC
    periphemu.create("back","speaker")
    config.set("standardsMode",true)
end

local args = {...}
local pod = {}
local speaker = peripheral.find("speaker")
local GlobalSongsList = {}
local speakerlib = require("/lib/speakerlib")
local PrimeUI = require("/lib/PrimeUI")
local webserver_URL = "https://pocketpod.leakedbuffalo79.repl.co/songs"

if not speaker then -- Check if there is a speaker
  error("No Speaker Stinky",0)
end

local function getSongsList() 
  local SongsFile, msg = http.get(webserver_URL)
  if not SongsFile then
    error(msg)
  end

  GlobalSongsList = textutils.unserialiseJSON(SongsFile.readAll())
  SongsFile.close()
  
  if not GlobalSongsList then
    error("Json Format Error",0)
  end

end
local function getSongInfo(song) 
  return song.SongName

end
local function playSong(songName) 
  local url = ""
  for k,v in pairs(GlobalSongsList) do
    if v.SongName == songName then 
      url = "?Song=" .. v.FileHost
    end
  end
  PrimeUI.addTask(function()
    speakerlib.playDfpwmMono(webserver_URL .. "/files" .. url)
  end)
end
local function DrawScreen() 
  PrimeUI.clear()
  local titlewidth = #("Pocket Pod") / 2
  local w, h = term.getSize()
  PrimeUI.label(term.current(), w / 2 - titlewidth, 2, "Pocket Pod")
  PrimeUI.horizontalLine(term.current(), w / 2 - titlewidth - 2, 3, #("Pocket Pod") + 4)
  local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, DescriptionEntry[1])
  PrimeUI.borderBox(term.current(), 3, 6, w - 4, 8)
  PrimeUI.selectionBox(term.current(), 3, 6, w - 4, 8, NameEntrys, function(entry) playSong(entry) end, function(option) redraw(DescriptionEntry[option]) end)
  PrimeUI.run()
end
pod.run = function (arguments)
  getSongsList()
  NameEntrys = {}
  DescriptionEntry = {}
  for k,v in pairs(GlobalSongsList) do
    table.insert(NameEntrys, v.SongName)
    table.insert(DescriptionEntry, v.SongName .. " - " .. v.Artist)
  end
  DrawScreen()
end
pod.play = function (arguments)
  speakerlib.playDfpwmMono(arguments[1])
end


command = table.remove(args, 1)

if pod[command] then
    pod[command](args)
end