local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport

local bedwarsidtable = {
    6872274481,
    8444591321,
    8560631822
}

local bridgeduelidtable = {
    11630038968
}

local BedWarsgame = table.find(bedwarsidtable, placeid)
local BridgeDuelgame = table.find(bridgeduelidtable, placeid)
local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
shared.AristoisPlaceId = ""
shared.SwitchServers = false 

if BedWarsgame then 
    shared.AristoisPlaceId = 6872274481
elseif BridgeDuelgame then
    shared.AristoisPlaceId = 11630038968
else
    shared.AristoisPlaceId = game.PlaceId
end

if shared.AristoisPlaceId == 6872274481 or shared.AristoisPlaceId == 11630038968 then
    if shared.ReadFile then
        loadstring(readfile("Aristois/Games/" .. shared.AristoisPlaceId .. ".lua"))()
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Games/" .. shared.AristoisPlaceId .. ".lua"))()
    end
else
    local placeFilePrivate = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
    if isfile(placeFilePrivate) then
        loadstring(readfile(placeFilePrivate))()
    else
        if shared.ReadFile then
            loadstring(readfile("Aristois/Universal.lua"))()
        else
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/Universal.lua"))()
        end
    end
end

local ServerSwitchScript = [[
    shared.SwitchServers = true 
    if shared.ReadFile then 
        loadstring(readfile("Aristois/NewMainScript.lua"))() 
    else 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XzynAstralz/Aristois/main/NewMainScript.lua", true))() 
    end
]]

if shared.SwitchServers then
    GuiLibrary:SaveConfiguration()
end

queueonteleport(ServerSwitchScript)
