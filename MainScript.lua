local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport
local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
local bedwarsidtable = {
    6872274481,
    8444591321,
    8560631822
}

local bridgeduelidtable = {
    11630038968
}

local BedWarsgame = table.find(bedwarsidtable, game.PlaceId)
local BridgeDuelgame = table.find(bridgeduelidtable, game.PlaceId)
shared.AristoisPlaceId = ""
shared.SwitchServers = false 
if BedWarsgame then 
    shared.AristoisPlaceId = 6872274481
elseif BridgeDuelgame then
    shared.AristoisPlaceId = 11630038968
else
    shared.AristoisPlaceId = game.PlaceId
end

assert(not shared.Executed, "Already Injected")
shared.Executed = true

if shared.AristoisPlaceId == 6872274481 or shared.AristoisPlaceId == 11630038968 then
    loadstring(readfile("Aristois/Games/" .. shared.AristoisPlaceId .. ".lua"))()
else
    local placeFilePrivate = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
    if isfile(placeFilePrivate) then
        loadstring(readfile(placeFilePrivate))()
    else
        loadstring(readfile("Aristois/Universal.lua"))()
    end
end

local configLoop = coroutine.create(function()
    repeat
        GuiLibrary.SaveConfiguration()
        task.wait(10)
    until shared.SwitchServers or not shared.Executed
end)

coroutine.resume(configLoop)

local ServerSwitchScript = [[
    shared.SwitchServers = true 
    loadstring(readfile("Aristois/NewMainScript.lua"))()
]]

if shared.SwitchServers then
    GuiLibrary.SaveConfiguration()
end

queueonteleport(ServerSwitchScript)
