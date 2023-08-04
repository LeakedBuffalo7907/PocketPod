if periphemu then -- probably on CraftOS-PC
    periphemu.create("back","speaker")
    config.set("standardsMode",true)
end

local args = {...}
local pod = {}
local speaker = peripheral.find("speaker")
local baseRepoURL = "http://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local ConfigFile = fs.open("/Config.txt", "r")
local webserver_URL = ConfigFile.readAll()
ConfigFile.close()
local GlobalSongsList = {}
local dfpwm = require("cc.audio.dfpwm")
local PrimeUI = require("/lib/PrimeUI")
local LocalVersion = 0.00

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function rand()
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

if fs.exists("/CurrentVersion.txt") then
  local webversion = http.get(baseRepoURL .. "/CurrentVersion.txt")
  local currentVersion = webversion.readAll()
  webversion.close()
  local F = fs.open("/CurrentVersion.txt", "r")
  LocalVersion = F.readAll()
  F.close()
  if currentVersion > LocalVersion then
    term.setTextColor(colors.red)
    print("Pocket Pod is out of date! Do you want to update?")
    print("Space to cancel - Enter to update")
    local uptodate = false
    while not uptodate do
      local events = {os.pullEvent()}
      if events[1] == "key" then
        if events[2] == keys.space then
          uptodate = true
          break
        elseif events[2] == keys.enter then
        shell.run("wget run " .. baseRepoURL .. "/install.lua")
        end

      end

    end

  end
end

if not speaker then -- Check if there is a speaker
  error("No Speaker Stinky",0)
end

local function getSongsList() 
  local SongsFile, msg = http.get(webserver_URL .. "/songs")
  if not SongsFile then
    error(msg)
  end

  GlobalSongsList = textutils.unserialiseJSON(SongsFile.readAll())
  SongsFile.close()
  
  if not GlobalSongsList then
    error("Json Format Error",0)
  end

end
local playingmusic = false
local function playSong(songName) 
  term.setCursorPos(1,1)
  local url = ""
  for k,v in pairs(GlobalSongsList) do
    if v.SongName == songName then 
      url = "?Song=" .. v.FileHost
    end
  end
  PrimeUI.addTask(function()
    playingmusic = true
    local decoder = dfpwm.make_decoder()
    local chunk = ""
    data = http.get(webserver_URL .. "/songs/files" .. url, nil, true)
    while chunk do
      chunk = data.read(0.5*1024)
        local buffer = decoder(chunk)
    
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
            playingmusic = false
        end
    end
  
  end)
    -- speakerlib.playDfpwmMono(webserver_URL .. "/songs/files" .. url)
end
local mixmusic = false
local function playMix()
  if mixmusic and not playingmusic then
    math.randomseed(os.time())
    local Random = math.floor(rand()*tablelength(GlobalSongsList)) + 1
    playSong(GlobalSongsList[Random].SongName)
  end
end
local function DrawScreen() 
  PrimeUI.clear()
  local titlewidth = #("Pocket Pod " .. LocalVersion) / 2 + 2
  local w, h = term.getSize()
  PrimeUI.label(term.current(), w / 2 - titlewidth, 2, "Pocket Pod " .. LocalVersion, colors.cyan)
  PrimeUI.horizontalLine(term.current(), w / 2 - titlewidth - 2, 3, #("Pocket Pod " .. LocalVersion) + 4, colors.blue)
  local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, DescriptionEntry[1])
  PrimeUI.borderBox(term.current(), 3, 6, w - 4, 8)
  PrimeUI.selectionBox(term.current(), 3, 6, w - 4, 8, NameEntrys, function(entry) playSong(entry) end, function(option) redraw(DescriptionEntry[option]) end, colors.white,colors.black,colors.blue)
  PrimeUI.button(term.current(), 3, h , "Exit", function() term.setBackgroundColor(colors.black) term.setTextColor(colors.white) term.clear() term.setCursorPos(1,1) print("Thank you for using Pocket Pod") error("", -1) end)
  PrimeUI.label(term.current(), w - 7, h, "[", colors.gray)
  PrimeUI.label(term.current(), w - 5, h, "] Mix", colors.gray)
  PrimeUI.keyAction(keys.m, function() if mixmusic then PrimeUI.label(term.current(), w - 6, h, "M", colors.lime) playMix() elseif not mixmusic then PrimeUI.label(term.current(), w - 6, h, "M", colors.white) end mixmusic = not mixmusic end)
  PrimeUI.label(term.current(), w - 6, h, "M", colors.white)
  PrimeUI.run()
end
pod.run = function (arguments)
  getSongsList()
  NameEntrys = {}
  DescriptionEntry = {}
  for k,v in pairs(GlobalSongsList) do
    table.insert(NameEntrys, v.SongName)
    table.insert(DescriptionEntry,"Song: " .. v.SongName .. " \nArtist: " .. v.Artist)
  end
  DrawScreen()
end
pod.play = function (arguments)
  local decoder = dfpwm.make_decoder()
  local chunk = ""
  data = http.get(arguments[1], nil, true)
  while chunk do
    chunk = data.read(0.5*1024)
      local buffer = decoder(chunk)
  
      while not speaker.playAudio(buffer) do
          os.pullEvent("speaker_audio_empty")
      end
  end
  
end
pod.weburl = function (arguments)
  if arguments[1] then
  local ConfigEdit = fs.open("/Config.txt", "w")
  ConfigEdit.write(arguments[1])
  ConfigEdit.close()
  else
    local ConfigRead = fs.open("/Config.txt", "r")
    term.setTextColor(colors.blue)
    print(ConfigRead.readAll())
    term.setTextColor(colors.white)
    ConfigRead.close()
  end
end


command = table.remove(args, 1)

if pod[command] then
    pod[command](args)
end