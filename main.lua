local discordia = require("discordia")
local request = require("request")
local http,https = require('http'),require('https')
coro = require'coro-http'
local json = require("json")
local readline = require("readline")


local client = discordia.Client()

local TOKEN=""

--discord doesnt allow "unverified bots" to view the contents of a message, but still recieves it, so i will detect when a message is sent then get the most recent message with a request

local CURRENT_CHANNEL = "CHANNEL ID"


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
        local guild_name = CHANNEL_DATA.parent.name

        --if the user is in a DM
        if CHANNEL_DATA.type == 1 then
            channel_name = CHANNEL_DATA.name .. "'s DMs"
            guild_name = "DMs"
        end

        getMessage(CURRENT_CHANNEL, message.author.name, channel_name, guild_name)       
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


function getMessage(channel_id, author, channel_name, guild_name)
    coroutine.wrap(function ()
        local url = "https://discord.com/api/v8/channels/".. channel_id .."/messages"
        local header = {{"authorization", TOKEN}}
        result, body = coro.request('GET', url, header)
         
        local jsonData = json.decode(body)
        
        print("sent in: " .. channel_name .. " in: " .. guild_name .. "\n".. author .. ": " ..jsonData[1]["content"] .. "\n")
        
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

function loginToDiscord(Email, Password)

    local url = "https://discord.com/api/v8/auth/login"
    local header = {{"Content-Type","application/json"}}
    local payload = json.encode{email = Email, password = Password}

    local res, body = coro.request("POST", url, header, payload, 500)
    if res.code < 200 or res.code >= 300 or json.decode(body).token == nil then
        print("FAILED TO LOGIN: " .. res.reason .. ": " .. res.code)
        print("please login with token and try again")
    else
        print("loggin successfull")
        print()
    
        TOKEN =tostring(json.decode(body).token)

    end
end





function init(email, password)

    loginToDiscord(email, password)
    client:run(TOKEN,{afk=true})

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

    editor:readLine(prompt, onLine)

end

print("LOGIN")

-- local state = 0
-- local email = ""
-- local password = ""


-- local init_prompt = ""
-- local init_editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle})
-- local function init_onLine(err, line, ...)
--     if line then
--         if state == 0 then
--             email = line
--             state = 1
--             print("PASSWORD")
--             init_editor:readLine(init_prompt, init_onLine)
--         elseif state == 1 then
--             password = line
--             state = 2
--             print(email)
--             print(password)
--             init(email, password)
--         end
--     else
--         --process:exit()
--     end
-- end
-- print("ENTER EMAIL")
-- init_editor:readLine(init_prompt, init_onLine)


init("EMAIL","PASSWORD")

--client:run(BOT_TOKEN)
