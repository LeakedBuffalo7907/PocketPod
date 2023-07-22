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
        error("No URL was provided")
    end
    local url = arguments[1]

    local youcubeapi = YouCubeAPI.API.new()
    local audiodevice = YouCubeAPI.Speaker.new(speaker)

    audiodevice:validate()
    print("about to connect")
    youcubeapi:detect_bestest_server()
    print("server found")
    
    local function run(_url, no_close)
      print("Requesting media ...")
      local data = youcubeapi:request_media(_url)

      if data.action == "error" then
          error(data.message)
      end

      local chunkindex = 0

      while true do
        local chunk = youcubeapi:get_chunk(chunkindex, data.id)
          if chunk == "mister, the media has finished playing" then
            print()
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