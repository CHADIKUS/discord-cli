local discordia = require("discordia")
local request = require("request")
local http,https = require('http'),require('https')
coro = require'coro-http'
local json = require("json")
local readline = require("readline")


local client = discordia.Client()

local TOKEN="USER TOKEN HERE"

--discord doesnt allow "unverified bots" to view the contents of a message, but still recieves it, so i will detect when a message is sent then get the most recent message with a request

local CURRENT_CHANNEL = "957491338859937822"


client:on("ready", function()
    print("LOGGED IN AS: " .. client.user.username)

    for guild_id, guild_data in pairs(client.guilds) do

    end
end)

client:on("messageCreate", function(message)
    --PRIVATE CHANNELS ARE DMS

    --this function activates when any messages from any server the user is in are recieved
    --so i just check if the message was sent in the same channel
    if message.channel.id == CURRENT_CHANNEL then
        local CHANNEL_DATA = client:getChannel(CURRENT_CHANNEL)

        local channel_name = CHANNEL_DATA.name
        --if the user is in a DM
        if CHANNEL_DATA.type == 1 then
            channel_name = CHANNEL_DATA.name .. "'s DMs"
        end

        getMessage(CURRENT_CHANNEL, message.author.name, channel_name)       
    end

    -- for k, v in pairs(client.guilds) do
    --     print(k, v)
    --     print(type(k))
    --     print(v[1])
    --     print(client:getGuild(k))
    --     for k, v in pairs(client:getGuild(k)) do
    --         print(k, v)
    --     end
    -- end

    -- for k, v in pairs(client.privateChannels) do
    --     print(k, v)
    -- end
    
end)


function getMessage(channel_id, author, channel_name)
    coroutine.wrap(function ()
        local url = "https://discord.com/api/v8/channels/".. channel_id .."/messages"
        local header = {{"authorization", TOKEN}}
        result, body = coro.request('GET', url, header)
         
        local jsonData = json.decode(body)
        
        print("sent in: " .. channel_name .."\n".. author .. ": " ..jsonData[1]["content"] .. "\n")
        
      end)()
      
end


function sendMessage(channel_id, message)
    coroutine.wrap(function()
        local url = "https://discord.com/api/v8/channels/"..channel_id.."/messages"
        local header = {{"authorization", TOKEN},{"Content-Type", "application/json"}}
        local payload = json.encode{content = message}

        local res = coro.request("POST", url, header, payload, 5000)
        if res.code < 200 or res.code >= 300 then
            return print("FAILED TO SEND MESSAGE: " .. res.reason .. ": " .. res.code)
        end
        print("message sent!")
    end)()    

end

local prompt = ""
local history = readline.History.new()
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history})
local function onLine(err, line, ...)
    if line then
        sendMessage(CURRENT_CHANNEL, line)
        editor:readLine(prompt, onLine)
    else
        process:exit()
    end
end

client:run(TOKEN,{afk=true})
editor:readLine(prompt, onLine)
--client:run(BOT_TOKEN)
