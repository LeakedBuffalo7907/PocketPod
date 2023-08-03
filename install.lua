local baseRepoURL = "http://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"


local function downloadFile(path, name)
  if fs.exists(path .. name) then
    fs.delete(path .. name)
  local F = fs.open(path .. name, "w")
  F.write(http.get(baseRepoURL .. path .. name).readAll())
  F.close()
  print(name .. " Downloaded")
end

  local uptodate = false
  local currentVersion = "0.00"
  local oldUser = fs.exists("/CurrentVersion.txt")
  if oldUser then
    local h = fs.open("/CurrentVersion.txt", "r")
    local webversion = http.get(baseRepoURL .. "/CurrentVersion.txt")
    currentVersion = webversion.readAll()
    uptodate = string.find(h.readAll(), currentVersion)
    h.close()
    webversion.close()
  end

  if uptodate then
    print("Pocket Pod Up To Date " .. currentVersion)
    return
  end

  if oldUser then
    print("Detected old install, Updating now")
  else
    print("Installing now")
  end
  downloadFile("/", "CurrentVersion.txt")
  downloadFile("/", "PodOS.lua")
  downloadFile("/lib/", "semver.lua")
  downloadFile("/lib/", "youcubeapi.lua")
  downloadFile("/lib/", "basalt.lua")
  print("Pocket Pod Installed " .. currentVersion)
  return;
    


