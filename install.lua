-- data[1].assets[1].browser_download_url
local apiURL = "http://api.github.com/repos/LeakedBuffalo7907/PocketPod/releases"
local baseRepoURL = "https://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local args = {...}
local skipcheck = false
local currentVersion = "0.0161"
if args and args[1] == "y" then
  skipcheck = true
end

http.request(apiURL)
print("Made request to " .. apiURL)
local updated = false
  if fs.exists("/PodOS.lua") then
    if fs.exists("/CurrentVersion.txt") then
      local h = fs.open("/CurrentVersion.txt", "r")
      if string.find(h.readAll(), currentVersion) then 
        print("Pocket Pod Up To Date " .. currentVersion)
        h.close()
        return 
      end
      h.close()
    end
    updated = true
    print("Pocket Pod Already Exists, Deleting old install")
    fs.delete("/CurrentVersion.txt")
    fs.delete("/PodOS.lua")
    fs.delete("/lib/semver.lua")
    fs.delete("/lib/youcubeapi.lua")
    fs.delete("/lib/basalt.lua")
  end

    print("Installing now")
    shell.run("wget " .. baseRepoURL .. "/PodOS.lua /PodOS.lua")

    print("Downloading libraries right now")
    shell.run("wget " .. baseRepoURL .. "/lib/semver.lua /lib/semver.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/youcubeapi.lua /lib/youcubeapi.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/basalt.lua /lib/basalt.lua")
    shell.run("wget " .. baseRepoURL .. "/CurrentVersion.txt /CurrentVersion.txt")
    if updated then
      print("Pocket Pod has Updated " .. currentVersion)

    else 
      print("Pocket Pod Installed " .. currentVersion)
    end

    return
    


