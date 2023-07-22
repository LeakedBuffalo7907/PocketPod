if periphemu then -- probably on CraftOS-PC
    periphemu.create("back","speaker")
    config.set("standardsMode",true)
end

settings.load()
local autoUpdates = settings.get("PocketPod.autoUpdates",true)
local modemBroadcast = settings.get("PocketPod.broadcast", true)
local dfpwm = require("cc.audio.dfpwm")
local version = "2.5.0"
local args = {...}
local pod = {}
local speaker = peripheral.find("speaker")
local serverChannel = 2561
local modem = peripheral.find("modem")
local v = require("/lib/semver")
local YouCubeAPI = require("/lib/youcubeapi")

if not speaker then -- Check if there is a speaker
  error("No Speaker",0)
end

pod.play = function (arguments)
    if not arguments or not arguments[1] then
      print("No Song Provided")
      return
    end
    local url = arguments[1]

    local youcubeapi = YouCubeAPI.API.new()
    local audiodevice = YouCubeAPI.Speaker.new(speaker)

    audiodevice:validate()
    youcubeapi:detect_bestest_server()
    
    local function run(_url, no_close)

      local chunkindex = 0

      while true do
        local chunk = youcubeapi:get_chunk(chunkindex, _url)
          if chunk == "mister, the media has finished playing" then
            if data.playlist_videos then
                return data.playlist_videos
            end

            if no_close then
                return
            end

            youcubeapi.websocket.close()
            return
          end
          audiodevice:write(chunk)
          chunkindex = chunkindex + 1
      end
    end

    local playlist_videos = run(url)

    if playlist_videos then
        for i, id in pairs(playlist_videos) do
            run(id, true)
        end
    end
end


command = table.remove(args, 1)
pod.index = index

if pod[command] then
    pod[command](args)
end