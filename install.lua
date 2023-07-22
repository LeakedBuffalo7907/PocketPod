local baseRepoURL = "https://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"
local currentVersion = "0.022"

local function updateFile(path, name)
  fs.delete(path .. name)
  shell.run("wget " .. baseRepoURL .. path .. name .. " " .. path .. name)
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
    shell.run("wget " .. baseRepoURL .. "/PodOS.lua /PodOS.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/semver.lua /lib/semver.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/youcubeapi.lua /lib/youcubeapi.lua")
    shell.run("wget " .. baseRepoURL .. "/lib/basalt.lua /lib/basalt.lua")
    shell.run("wget " .. baseRepoURL .. "/CurrentVersion.txt /CurrentVersion.txt")
    print("Pocket Pod Installed " .. currentVersion)

  end
    if updated then
      

    else 
      
    end

    return
    


