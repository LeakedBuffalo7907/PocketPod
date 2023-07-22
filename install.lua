local baseRepoURL = "http://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local currentVersion = "0.0263"

local function updateFile(path, name)
  fs.delete(path .. name)
  local newFile = http.get(baseRepoURL .. path .. name)
  local F = fs.open(path .. name, "w")
  F.write(newFile.readAll())
  newFile.close()
  F.close()
  print(name .. " Updated")
end
local function downloadFile(path, name)
  local F = fs.open(path .. name, "w")
  F.write(http.get(baseRepoURL .. path .. name).readAll())
  F.close()
  print(name .. " Downloaded")
end

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
    updateFile("/", "CurrentVersion.txt")
    updateFile("/", "PodOS.lua")
    updateFile("/lib/", "semver.lua")
    updateFile("/lib/", "youcubeapi.lua")
    updateFile("/lib/", "basalt.lua")
    print("Pocket Pod has Updated " .. currentVersion)
    return

  else
    print("Installing now")
    downloadFile("/", "CurrentVersion.txt")
    downloadFile("/", "PodOS.lua")
    downloadFile("/lib/", "semver.lua")
    downloadFile("/lib/", "youcubeapi.lua")
    downloadFile("/lib/", "basalt.lua")
    print("Pocket Pod Installed " .. currentVersion)

  end
    if updated then
      

    else 
      
    end

    return
    


