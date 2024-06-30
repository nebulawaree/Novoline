local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end
local folders = {"Novoline", "Novoline/Games", "Novoline/Librarys", "Novoline/assets"}
for _, folder in ipairs(folders) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/HimynameisLOL/Novoline/commits")
    local commits = game:GetService("HttpService"):JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local betterisfile = function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil
end

local function downloadFileAsync(url, filePath)
    local success, response = pcall(function()
        return game:HttpGetAsync(url)
    end)
    if success then
        writefile(filePath, response)
    end
end

local function updateAvailable()
    local latestCommit = fetchLatestCommit()
    if latestCommit then
        local lastCommitFile = "Novoline/commithash.txt"
        if not isfile(lastCommitFile) then
            return true, latestCommit
        end
        local lastCommit = readfile(lastCommitFile)
        return lastCommit ~= latestCommit or latestCommit == "main", latestCommit
    end
    return false, nil
end

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/HimynameisLOL/Novoline/" .. commitHash .. "/"
    local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Librarys/Utility.lua", "Games/11630038968.lua", "Games/6872274481.lua"}
    local threads = {}
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "HimynameisLOL/" .. filePath
        if not betterisfile(localFilePath) or updateAvailable() then
            local fileUrl = baseUrl .. filePath
            table.insert(threads, coroutine.create(function()
                downloadFileAsync(fileUrl, localFilePath)
            end))
        end
    end
    for _, thread in ipairs(threads) do
        coroutine.resume(thread)
    end
    for _, thread in ipairs(threads) do
        while coroutine.status(thread) ~= "dead" do
            wait()
        end
    end
    writefile("Novoline/commithash.txt", commitHash)
end

if not betterisfile("Novoline/assets/cape.png") then
    local req = requestfunc({
        Url = "https://github.com/HimynameisLOL/Novoline/raw/main/assets/cape.png",
        Method = "GET"
    })
    writefile("Novoline/assets/cape.png", req.Body)
end

local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Librarys/Utility.lua", "Games/11630038968.lua", "Games/6872274481.lua"}
for _, filePath in ipairs(filesToUpdate) do
    if not betterisfile("Novoline/" .. filePath) then
        local fileUrl = "https://raw.githubusercontent.com/HimynameisLOL/Novoline/main/" .. filePath
        downloadFileAsync(fileUrl, "Novoline/" .. filePath)
    end
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    updateFiles(latestCommit)
end

if not shared.Executed then
    loadstring(readfile("Novoline/MainScript.lua"))()
else
    warn("cannot run all ready Executed")
end
