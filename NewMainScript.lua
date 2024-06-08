if not isfolder("Aristois") then
    makefolder("Aristois")
end

if not isfolder("Aristois/Games") then
    makefolder("Aristois/Games")
end

if not isfolder("Aristois/Librarys") then
    makefolder("Aristois/Librarys")
end

if not isfolder("Aristois/assets") then
    makefolder("Aristois/assets")
end

local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/XzynAstralz/Aristois/commits")
    local commits = game:GetService("HttpService"):JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local function fileExists(filePath)
    local success, _ = pcall(function() return readfile(filePath) end)
    return success
end

local function downloadFile(url, filePath)
    local response = game:HttpGet(url, true)
    if response then
        writefile(filePath, response)
    end
end

local function updateAvailable()
    local latestCommit = fetchLatestCommit()
    if latestCommit then
        local lastCommitFile = "Aristois/commithash.txt"
        if not isfile(lastCommitFile) then
            return true, latestCommit
        end
        local lastCommit = readfile(lastCommitFile)
        return lastCommit ~= latestCommit or latestCommit == "main", latestCommit
    end
    return false, nil
end

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/XzynAstralz/Aristois/" .. commitHash .. "/"
    local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Games/11630038968.lua"}
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "Aristois/" .. filePath
        if not fileExists(localFilePath) or updateAvailable() then
            local fileUrl = baseUrl .. filePath
            downloadFile(fileUrl, localFilePath)
        end
    end
    writefile("Aristois/commithash.txt", commitHash)
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    updateFiles(latestCommit)
end

return loadstring(readfile("Aristois/MainScript.lua"))()
