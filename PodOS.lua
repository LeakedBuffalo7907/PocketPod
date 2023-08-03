if periphemu then -- probably on CraftOS-PC
    periphemu.create("back","speaker")
    config.set("standardsMode",true)
end

local version = "1.0.0"
local args = {...}
local pod = {}
local speaker = peripheral.find("speaker")
local GlobalSongsList = {}
local speakerlib = require("/lib/speakerlib")
local webserver_URL = "https://computercraftmp3.leakedbuffalo79.repl.co"

if not speaker then -- Check if there is a speaker
  error("No Speaker",0)
end

local function getSongsList() 
  local SongsFile, msg = http.get(webserver_URL .. "/songs")
  if not SongsFile then
    error(msg)
  end

  GlobalSongsList = textutils.unserialiseJSON(SongsFile.readAll())
  SongsFile.close()
  
  if not GlobalSongsList then
      error("json data malformed",0)
  end

end

pod.play = function (arguments)
    
end


command = table.remove(args, 1)

if pod[command] then
    pod[command](args)
end