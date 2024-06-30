local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function()
    error("No HTTP request function is available")
end

print("Using request function: " .. (syn and "syn.request" or http and "http.request" or http_request and "http_request" or fluxus and "fluxus.request" or request and "request" or "None"))

local folders = {"Novoline", "Novoline/Games", "Novoline/Librarys", "Novoline/assets"}

for _, folder in ipairs(folders) do
    if isfolder(folder) then
        delfolder(folder)
        print("Deleted existing folder: " .. folder)
    end
    makefolder(folder)
    print("Created folder: " .. folder)
end

local function fetchLatestCommit()
    local success, response = pcall(function()
        return game:HttpGet("https://api.github.com/repos/nebulawaree/Novoline/commits")
    end)
    if success then
        local commits = game:GetService("HttpService"):JSONDecode(response)
        if commits and #commits > 0 then
            print("Latest commit SHA: " .. commits[1].sha)
            return commits[1].sha
        else
            warn("No commits found in the repository.")
        end
    else
        warn("Failed to fetch latest commit: " .. response)
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
        local fileCreationSuccess, fileCreationError = pcall(function()
            writefile(filePath, response)
        end)
        if fileCreationSuccess then
            print("Successfully downloaded and saved: " .. filePath)
        else
            warn("Failed to create file: " .. filePath .. " Error: " .. fileCreationError)
        end
    else
        warn("Failed to download file from URL: " .. url .. " Error: " .. response)
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
        return lastCommit ~= latestCommit, latestCommit
    end
    return false, nil
end

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/nebulawaree/Novoline/main/"
    local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Librarys/Utility.lua", "Games/11630038968.lua", "Games/6872274481.lua"}
    local threads = {}
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "Novoline/" .. filePath
        if not betterisfile(localFilePath) or updateAvailable() then
            local fileUrl = baseUrl .. filePath
            print("Downloading file from URL: " .. fileUrl)
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
        Url = "https://github.com/nebulawaree/Novoline/raw/main/assets/cape.png",
        Method = "GET"
    })
    if req and req.Body then
        local success, err = pcall(function()
            writefile("Novoline/assets/cape.png", req.Body)
        end)
        if success then
            print("Successfully downloaded and saved cape.png")
        else
            warn("Failed to create cape.png file: " .. err)
        end
    else
        warn("Failed to download cape.png: " .. (req and req.StatusMessage or "Request failed"))
    end
else
    print("cape.png already exists")
end

local filesToUpdate = {"NewMainScript.lua", "MainScript.lua", "GuiLibrary.lua", "Universal.lua", "Librarys/Whitelist.lua", "Librarys/Utility.lua", "Games/11630038968.lua", "Games/6872274481.lua"}
for _, filePath in ipairs(filesToUpdate) do
    if not betterisfile("Novoline/" .. filePath) then
        local fileUrl = "https://raw.githubusercontent.com/nebulawaree/Novoline/main/" .. filePath
        print("Downloading file from URL: " .. fileUrl)
        downloadFileAsync(fileUrl, "Novoline/" .. filePath)
    else
        print(filePath .. " already exists")
    end
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    print("Update available. Latest commit: " .. latestCommit)
    updateFiles(latestCommit)
else
    print("No updates available")
end

if not shared.Executed then
    local mainScriptPath = "Novoline/MainScript.lua"
    if betterisfile(mainScriptPath) then
        print("Executing MainScript.lua")
        local success, err = pcall(function()
            loadstring(readfile(mainScriptPath))()
        end)
        if not success then
            warn("Failed to execute MainScript.lua: " .. err)
        end
    else
        warn("MainScript.lua does not exist.")
    end
else
    warn("Cannot run, already executed.")
end
