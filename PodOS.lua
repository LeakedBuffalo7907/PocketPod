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
local function drawEntries()
  local w, h = term.getSize()
    term.clear()
    term.setCursorPos((w - #"PodOS") / 2, 2)
    term.setTextColor(16384)
    term.write("PodOS")
    term.setCursorPos(5, h - 3)
    term.write("test line 1")
    term.setCursorPos(5, h - 2)
    term.write("test line 2")
    term.setCursorPos(5, h - 1)
    term.write("test line 3")
end

local selection = 1
while true do
  local event, key = os.pullEvent("key")
  if key and event then 
    drawEntries();
  end
  if key == keys.up and selection > 1 then
    selection = selection - 1
    drawEntries(selection, entries)
  elseif key == keys.down and selection < 3 then
    selection = selection + 1
    drawEntries(selection, entries)
  elseif key == keys.enter then
    if selection == 1 then 
      -- button 1
    end
  end
end

pod.start = function ()
  drawEntries()
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