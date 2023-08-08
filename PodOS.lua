if periphemu then -- probably on CraftOS-PC
    periphemu.create("back","speaker")
    config.set("standardsMode",true)
end

local args = {...}
local pod = {}
local DrawScreen
local DrawSettings

local NameEntrys = {}
local DescriptionEntry = {}
local WebURLsArray = {}
local SettingsEntrys = {"Return","Change Music Server","Change Theme"}

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
    print("Pocket Pod is out of date!")
    print("Do you want to update?")
    print("Space to cancel") 
    print("Enter to update")
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

  for k,v in pairs(GlobalSongsList) do
    table.insert(NameEntrys, v.SongName)
    table.insert(DescriptionEntry,"Song: " .. v.SongName .. " \nArtist: " .. v.Artist)
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
  playingmusic = true
  local decoder = dfpwm.make_decoder()
  local chunk = ""
  data = http.get(webserver_URL .. "/songs/files" .. url, nil, true)
  if not data or data == nil then
    speaker.stop(); return;
  end
  PrimeUI.addTask(function()
    while chunk do
      chunk = data.read(0.5*1024)
      if not data or not chunk then
        while true do 
        os.pullEvent()
        end
      end
      if turtle then
turtle.TurnLeft()
      end
        local buffer = decoder(chunk)
        if not playingmusic then
          speaker.stop()
          while true do os.pullEvent() end
        end
        while not speaker.playAudio(buffer) do
          os.pullEvent("speaker_audio_empty")
        end
    end
  
  end)
    -- speakerlib.playDfpwmMono(webserver_URL .. "/songs/files" .. url)
end
local mixmusic = false
local showsettings = false
local function playMix()
  if mixmusic and not playingmusic then
    math.randomseed(os.time())
    local Random = math.floor(rand()*tablelength(GlobalSongsList)) + 1
    playSong(GlobalSongsList[Random].SongName)
  end
end
local Settings = {}
Settings.Themes = function() 

end
Settings.WebURL = function()
  PrimeUI.clear()
  PrimeUI.label(term.current(), 3, 5, "Add Streaming Server")
  PrimeUI.borderBox(term.current(), 4, 7, 40, 1)
  PrimeUI.inputBox(term.current(), 4, 7, 40, function(textoutput) table.insert(WebURLsArray, textoutput) end)
  for k,v in pairs(WebURLsArray) do
    PrimeUI.label(term.current(), 2, 9, v)
  end
  PrimeUI.run()

end
local function processSetting(entry) 
  if entry == SettingsEntrys[1] then
    DrawScreen()
  elseif entry == SettingsEntrys[2] then
    Settings.WebURL()
  elseif entry == SettingsEntrys[3] then
    Settings.Themes()
  end
end
DrawSettings = function()

  PrimeUI.clear()
  local titlewidth = #("Pocket Settings " .. LocalVersion) / 2 + 2
  local w, h = term.getSize()
  PrimeUI.label(term.current(), w / 2 - titlewidth, 2, "Pocket Settings " .. LocalVersion, colors.cyan)
  PrimeUI.horizontalLine(term.current(), w / 2 - titlewidth - 2, 3, #("Pocket Settings " .. LocalVersion) + 4, colors.blue)
  PrimeUI.borderBox(term.current(), 3, 6, w - 4, 8)
  PrimeUI.selectionBox(term.current(), 3, 6, w - 4, 8, SettingsEntrys, function(entry) processSetting(entry)  end, function(option)  end, colors.white,colors.black,colors.blue)



end
DrawScreen = function()
  PrimeUI.clear()
  local titlewidth = #("Pocket Pod " .. LocalVersion) / 2
  local w, h = term.getSize()
  PrimeUI.label(term.current(), w / 2 - titlewidth, 2, "Pocket Pod " .. LocalVersion, colors.cyan)
  PrimeUI.horizontalLine(term.current(), w / 2 - titlewidth - 2, 3, #("Pocket Pod " .. LocalVersion) + 4, colors.blue)
  local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, DescriptionEntry[1])
  PrimeUI.borderBox(term.current(), 3, 6, w - 4, 8)
  PrimeUI.selectionBox(term.current(), 3, 6, w - 4, 8, NameEntrys, function(entry) playSong(entry) end, function(option) redraw(DescriptionEntry[option]) end, colors.white,colors.black,colors.blue)
  PrimeUI.button(term.current(), 3, h , "Exit", function() term.setBackgroundColor(colors.black) term.setTextColor(colors.white) term.clear() term.setCursorPos(1,1) print("Thank you for using Pocket Pod") error("", -1) end)
  PrimeUI.label(term.current(), w - 11, h, "[", colors.gray)
  PrimeUI.label(term.current(), w - 9, h, "] Mix", colors.gray)
  PrimeUI.keyAction(keys.m, function() if mixmusic then PrimeUI.label(term.current(), w - 10, h, "M", colors.lime) playMix() elseif not mixmusic then PrimeUI.label(term.current(), w - 10, h, "M", colors.white) playingmusic = false end mixmusic = not mixmusic end)
  PrimeUI.label(term.current(), w - 10, h, "M", colors.white)

  PrimeUI.label(term.current(), w - 11, h - 1, "[", colors.gray)
  PrimeUI.label(term.current(), w - 9, h - 1, "] Settings", colors.gray)
  PrimeUI.keyAction(keys.s, function() 
  if showsettings then  
    PrimeUI.label(term.current(), w - 10, h - 1, "S", colors.lime)
    DrawSettings()
  elseif not showsettings then
    PrimeUI.label(term.current(), w - 10, h - 1, "S", colors.white)
  end
  showsettings = not showsettings 
  end)
  PrimeUI.label(term.current(), w - 10, h - 1, "S", colors.white)
  PrimeUI.run()
end
pod.run = function (arguments)
  getSongsList()
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