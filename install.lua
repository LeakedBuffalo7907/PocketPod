local baseRepoURL = "http://raw.githubusercontent.com/LeakedBuffalo7907/PocketPod/main"


local function downloadFile(path, name)
  if fs.exists(path .. name) then
    fs.delete(path .. name)
  end
  local F = fs.open(path .. name, "w")
  F.write(http.get(baseRepoURL .. path .. name).readAll())
  F.close()
  term.setTextColor(colors.lime)
  print(name .. " Downloaded")
  term.setTextColor(colors.white)
end

  local uptodate = false
  local webversion = http.get(baseRepoURL .. "/CurrentVersion.txt")
  local currentVersion = webversion.readAll()
  webversion.close()
  local oldUser = fs.exists("/CurrentVersion.txt")

  if oldUser then
    print("Detected old install, Updating now")
  else
    print("Installing now")
  end
  downloadFile("/", "CurrentVersion.txt")
  downloadFile("/", "PodOS.lua")
  downloadFile("/lib/", "speakerlib.lua")
  term.setTextColor(colors.blue)
  print("Pocket Pod Installed " .. currentVersion)
  term.setTextColor(colors.white)
  return;
    


