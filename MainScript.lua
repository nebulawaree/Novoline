local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport
if not queueonteleport then
    error("queueonteleport function is not defined")
else
    print("queueonteleport function is defined")
end

local GuiLibrary

local games = {
    [6872274481] = "BedWars",
    [8444591321] = "BedWars",
    [8560631822] = "BedWars",
    [11630038968] = "BridgeDuel"
}

local currentGame = games[game.PlaceId]
shared.AristoisPlaceId = game.PlaceId
shared.SwitchServers = false 

if currentGame == "BedWars" then 
    shared.AristoisPlaceId = 6872274481
elseif currentGame == "BridgeDuel" then
    shared.AristoisPlaceId = 11630038968
end

assert(not shared.Executed, "Already Injected")
shared.Executed = true

local function fetchUrl(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        error("Failed to fetch " .. url .. ": " .. result)
    end
    return result
end

local function loadScript(content, scriptName)
    local success, result = pcall(function()
        return loadstring(content)()
    end)
    if not success then
        error("Failed to load " .. scriptName .. ": " .. result)
    end
    return result
end

local guiLibraryUrl = "https://raw.githubusercontent.com/nebulawaree/Novoline/main/GuiLibrary.lua"
local guiLibraryContent = fetchUrl(guiLibraryUrl)
GuiLibrary = loadScript(guiLibraryContent, "GuiLibrary.lua")
shared.GuiLibrary = GuiLibrary

local scriptPath = "Novoline/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
local isUniversal = not currentGame or not isfile(scriptPath)

if isUniversal then
    print("Fetching Universal.lua from URL")
else
    print("Loading game script from path: " .. scriptPath)
end

if isUniversal then
    local universalUrl = "https://raw.githubusercontent.com/nebulawaree/Novoline/main/Universal.lua"
    local universalContent = fetchUrl(universalUrl)
    loadScript(universalContent, "Universal.lua")
else
    if isfile(scriptPath) then
        local gameScriptContent = readfile(scriptPath)
        loadScript(gameScriptContent, scriptPath)
    else
        error("Game script does not exist at path: " .. scriptPath)
    end
end

local configLoop = coroutine.create(function()
    repeat
        GuiLibrary.SaveConfiguration()
        task.wait(10)
    until shared.SwitchServers or not shared.Executed
end)

local Window = shared.Window
if not Window then
    error("shared.Window is nil")
end

coroutine.resume(configLoop)

local ServerSwitchScript = [[
    shared.SwitchServers = true 
    loadstring(readfile("Novoline/NewMainScript.lua"))()
]]

if shared.SwitchServers then
    GuiLibrary.SaveConfiguration()
end

if not isfile("Novoline/configs/rememberJoin.txt") then
    task.wait()
    Window:Prompt({
        Title = 'Guide',
        SubTitle = 'How to see sections',
        Content = 'To see the other sections like ‘Blatant,’ click on the icon on the top right of the gui.',
        Actions = {
            Accept = {
                Name = 'Accept',
                Callback = function()
                    writefile("Novoline/configs/rememberJoin.txt", "this will not show you the Prompt")
                end,
            }
        }
    })
end

queueonteleport(ServerSwitchScript)
