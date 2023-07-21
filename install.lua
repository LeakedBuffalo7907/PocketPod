-- data[1].assets[1].browser_download_url
local apiURL = "http://api.github.com/repos/LeakedBuffalo7907/PocketPod/releases"
local baseRepoURL = "https://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local args = {...}
local skipcheck = false
if args and args[1] == "y" then
  skipcheck = true
end

local scKey = _G._GIT_API_KEY
if scKey then
  requestData = {
    url = apiURL,
    headers = {["Authorization"] = "token " .. scKey}
  }
  http.request(requestData)
else
  http.request(apiURL) -- when not on switchcraft, use no authentication
end
print("Made request to " .. apiURL)

    print("Installing now")
    shell.run("wget " .. baseRepoURL .. "/musicify.lua /musicify.lua")

    print("Downloading libraries right now")
    shell.run("wget " .. baseRepoURL .. "/lib/semver.lua /lib/semver.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/youcubeapi.lua /lib/youcubeapi.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/basalt.lua /lib/basalt.lua")
    print("Done!!")
    return
  end
end


