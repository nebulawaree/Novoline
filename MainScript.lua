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

-- Load GuiLibrary from the provided URL and check for errors
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/HimynameisLOL/Novoline/main/GuiLibrary.lua")
end)

if not success then
    error("Failed to fetch GuiLibrary.lua: " .. result)
end

success, result = pcall(function()
    return loadstring(result)()
end)

if not success then
    error("Failed to load GuiLibrary.lua: " .. result)
end

GuiLibrary = result
shared.GuiLibrary = GuiLibrary 

local scriptPath = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
local isUniversal = not currentGame or not isfile(scriptPath)

-- Debugging: Log the script path that is being used
if isUniversal then
    print("Fetching Universal.lua from URL")
else
    print("Loading game script from path: " .. scriptPath)
end

-- Load the game script or Universal.lua from the URL and check for errors
if isUniversal then
    success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/HimynameisLOL/Novoline/main/Universal.lua")
    end)
    if not success then
        error("Failed to fetch Universal.lua: " .. result)
    end
    success, result = pcall(function()
        return loadstring(result)()
    end)
else
    success, result = pcall(function()
        return loadstring(readfile(scriptPath))()
    end)
end

if not success then
    error("Failed to load game script: " .. result)
end

-- Coroutine for configuration saving loop
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

-- Server switch script
local ServerSwitchScript = [[
    shared.SwitchServers = true 
    loadstring(readfile("Aristois/NewMainScript.lua"))()
]]

if shared.SwitchServers then
    GuiLibrary.SaveConfiguration()
end

if not isfile("Aristois/configs/rememberJoin.txt") then
    task.wait()
    Window:Prompt({
        Title = 'Guide',
        SubTitle = 'How to see sections',
        Content = 'To see the other sections like ‘Blatant,’ click on the icon on the top right of the gui.',
        Actions = {
            Accept = {
                Name = 'Accept',
                Callback = function()
                    writefile("Aristois/configs/rememberJoin.txt", "this will not show you the Prompt")
                end,
            }
        }
    })
end

queueonteleport(ServerSwitchScript)
