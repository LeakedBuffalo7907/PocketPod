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
local webserver_URL = "https://pocketpod.leakedbuffalo79.repl.co"

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
  return song.Name

end

pod.run = function (arguments)
  getSongsList()
  for k,v in pairs(GlobalSongsList) do
    print(k,getSongInfo(v))
  end
end
pod.play = function (arguments)
  speakerlib.playDfpwmMono(arguments[1])
end


command = table.remove(args, 1)

if pod[command] then
    pod[command](args)
end