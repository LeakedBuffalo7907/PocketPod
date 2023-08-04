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
local speakerlib = require("/lib/speakerlib")
local PrimeUI = require("/lib/PrimeUI")
local LocalVersion = 0.00

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
        if events[2] == 57 then
          uptodate = true
          break
        elseif events[2] == 28 then
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
  local titlewidth = #("Pocket Pod " .. LocalVersion) / 2
  local w, h = term.getSize()
  PrimeUI.label(term.current(), w / 2 - titlewidth, 2, "Pocket Pod " .. LocalVersion, colors.cyan)
  PrimeUI.horizontalLine(term.current(), w / 2 - titlewidth - 2, 3, #("Pocket Pod " .. LocalVersion) + 4, colors.blue)
  local redraw = PrimeUI.textBox(term.current(), 3, 15, 40, 3, DescriptionEntry[1])
  PrimeUI.borderBox(term.current(), 3, 6, w - 4, 8)
  PrimeUI.selectionBox(term.current(), 3, 6, w - 4, 8, NameEntrys, function(entry) playSong(entry) end, function(option) redraw(DescriptionEntry[option]) end, colors.white,colors.black,colors.blue)
  PrimeUI.button(term.current(), 3, h , "Exit", function() term.setBackgroundColor(colors.black) term.setTextColor(colors.white) term.clear() term.setCursorPos(1,1) print("Thank you for using Pocket Pod") error("", -1) end)
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
pod.weburl = function (arguments)
  if arguments[1] then
  local ConfigEdit = fs.open("/Config.txt", "w")
  ConfigEdit.write(arguments[1])
  ConfigEdit.close()
  else
    local ConfigRead = fs.open("/Config.txt", "r")
    term.setTextColor(colors.blue)
    print(ConfigEdit.readAll())
    term.setTextColor(colors.white)
    ConfigEdit.close()
  end
end


command = table.remove(args, 1)

if pod[command] then
    pod[command](args)
end