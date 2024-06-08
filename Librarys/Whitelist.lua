local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end

local storedshahashes = {} 

local HashLib = loadstring(requestfunc({
    Url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/sha.lua",
    Method = "GET"
}).Body)()

local Whitelist = loadstring(requestfunc({
    Url = "https://raw.githubusercontent.com/XzynAstralz/Whitelist/main/list.lua",
    Method = "GET"
}).Body)()

local function hashUserData(userId, username)
    if not userId or not username then
        return nil
    end
    
    local HashFunction = function(str)
        if storedshahashes[tostring(str)] == nil then
            storedshahashes[tostring(str)] = HashLib.sha512(tostring(str).."SelfReport")
        end
        return storedshahashes[tostring(str)]
    end
    
    local userData = userId .. username
    return HashFunction(userData)
end

local function fetchUserData()
    local success, response = pcall(function()
        local userId = game.Players.LocalPlayer.UserId
        local hashedUserData = hashUserData(userId, game.Players.LocalPlayer.Name)
        return hashedUserData
    end)
    if success then
        return response
    else
        warn("Failed to fetch user data: " .. tostring(response))
        return nil
    end
end

local combinedHash = fetchUserData()

local ChatTagModule = {}

ChatTagModule.combinedHash = combinedHash

function ChatTagModule.checkstate(hashedUserData)
    return Whitelist[hashedUserData] ~= nil
end

function ChatTagModule.getCustomTag(hashedUserData)
    if Whitelist[hashedUserData] and Whitelist[hashedUserData].tags and Whitelist[hashedUserData].tags[1] then
        return Whitelist[hashedUserData].tags[1].text, Whitelist[hashedUserData].tags[1].color
    end
    return nil, nil
end

function rgbToHex(r, g, b)
    local hex = string.format("#%02x%02x%02x", r, g, b)
    return hex
end

function ChatTagModule.update_tag_meta()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextService = game:GetService("TextService")
    local TextChatService = ReplicatedStorage:FindFirstChild("TextChatService")

    local ChatTag = {}

    for i, v in pairs(Players:GetPlayers()) do
        if ChatTagModule.checkstate(ChatTagModule.combinedHash) then
            local tagText, tagColor = ChatTagModule.getCustomTag(ChatTagModule.combinedHash)
            if tagText and tagColor then
                ChatTag[v.UserId] = {
                    TagColor = tagColor,
                    TagText = tagText,
                    PlayerType = "PRIVATE"
                }
            else
                ChatTag[v.UserId] = {
                    TagColor = Color3.new(0.7, 0, 1),
                    TagText = "Aristois Private",
                    PlayerType = "PRIVATE"
                }
            end
        end
    end

    local oldchanneltabs = {}

    for i, v in pairs(getconnections(ReplicatedStorage.DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent)) do
        if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
            local oldchanneltab = getmetatable(debug.getupvalues(v.Function)[1])
            local oldchannelfunc = getmetatable(debug.getupvalues(v.Function)[1]).GetChannel
            getmetatable(debug.getupvalues(v.Function)[1]).GetChannel = function(Self, Name)
                local tab = oldchannelfunc(Self, Name)
                if tab and tab.AddMessageToChannel then
                    local addmessage = tab.AddMessageToChannel
                    if oldchanneltabs[tab] == nil then
                        oldchanneltabs[tab] = tab.AddMessageToChannel
                    end
                    tab.AddMessageToChannel = function(Self2, MessageData)
                        if MessageData.FromSpeaker and Players[MessageData.FromSpeaker] then
                            if ChatTag[Players[MessageData.FromSpeaker].UserId] then
                                MessageData.ExtraData = {
                                    NameColor = Players[MessageData.FromSpeaker].Team == nil and Color3.new(135, 206, 235) or Players[MessageData.FromSpeaker].TeamColor.Color,
                                    Tags = {
                                        table.unpack(MessageData.ExtraData.Tags),
                                        {
                                            TagColor = ChatTag[Players[MessageData.FromSpeaker].UserId].TagColor,
                                            TagText = ChatTag[Players[MessageData.FromSpeaker].UserId].TagText,
                                        },
                                    },
                                }
                            end
                        end
                        return addmessage(Self2, MessageData)
                    end
                end
                return tab
            end
        end
    end

    if TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            local properties = Instance.new("TextChatMessageProperties")
            if message.TextSource then
                local player = Players:GetPlayerByUserId(message.TextSource.UserId)
                if player and ChatTag[player.UserId] then
                    local r, g, b = ChatTag[player.UserId].TagColor.r * 255, ChatTag[player.UserId].TagColor.g * 255, ChatTag[player.UserId].TagColor.b * 255
                    local hexColor = rgbToHex(r, g, b)
                    properties.PrefixText = "<font color='" .. hexColor .. "'>[" .. ChatTag[player.UserId].TagText .. "]</font> " .. message.PrefixText
                end
            end
            return properties
        end
    end

    return ChatTag
end

return ChatTagModule
