local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport
if not queueonteleport then
    error("queueonteleport function is not defined")
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

-- Load GuiLibrary and check for errors
local success, result = pcall(function()
    return loadstring(readfile("Aristois/GuiLibrary.lua"))()
end)

if not success then
    error("Failed to load GuiLibrary.lua: " .. result)
end

GuiLibrary = result
shared.GuiLibrary = GuiLibrary 

local scriptPath = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
if not currentGame or not isfile(scriptPath) then
    scriptPath = "Aristois/Universal.lua"
end

-- Load the game script and check for errors
success, result = pcall(function()
    return loadstring(readfile(scriptPath))()
end)

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
