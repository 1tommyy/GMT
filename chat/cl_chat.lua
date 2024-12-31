local isRDR = not TerraingridActivate and true or false

local hideChat = false
local chatInputActive = false
local chatInputActivating = false
local chatLoaded = false
local isReducedOpacity = false
local isFirstLoad = true

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:addMode')
RegisterNetEvent('chat:removeMode')
RegisterNetEvent('chat:removeAllModes')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')

local specialSyntax = {
  ["^"] = true,
  ["."] = true,
  ["+"] = true,
  ["*"] = true,
  ["-"] = true,
  ["?"] = true,
}

local emojis = {
  [":sob:"] = "😭",
  [":smile:"] = "😄",
  [":laugh:"] = "😂",
  [":thumbs_up:"] = "👍",
  [":thumbs_down:"] = "👎",
  [":heart:"] = "❤️",
  [":broken_heart:"] = "💔",
  [":sunglasses:"] = "😎",
  [":angry:"] = "😠",
  [":astonished:"] = "😲",
  [":blush:"] = "😊",
  [":confused:"] = "😕",
  [":cry:"] = "😢",
  [":lemon:"] = "🍋",
  [":fearful:"] = "😨",
  [":fire:"] = "🔥",
  [":grin:"] = "😁",
  [":joy:"] = "😂",
  [":kiss:"] = "😘",
  [":like:"] = "👍",
  [":dislike:"] = "👎",
  [":love:"] = "❤️",
  [":sad:"] = "😔",
  [":surprise:"] = "😮",
  [":tongue:"] = "😛",
  [":wink:"] = "😉",
  [":100:"] = "💯",
  [":clap:"] = "👏",
  [":muscle:"] = "💪",
  [":peace:"] = "✌️",
  [":punch:"] = "👊",
  [":ok_hand:"] = "👌",
  [":wave:"] = "👋",
  [":victory:"] = "✌️",
  [":point_up:"] = "☝️",
  [":raised_hand:"] = "✋",
  [":fist:"] = "✊",
  [":facepalm:"] = "🤦",
  [":shrug:"] = "🤷",
  [":star:"] = "⭐",
  [":zap:"] = "⚡",
  [":boom:"] = "💥",
  [":ghost:"] = "👻",
  [":alien:"] = "👽",
  [":robot:"] = "🤖",
  [":poop:"] = "💩",
  [":eyes:"] = "👀",
  [":tada:"] = "🎉",
  [":gift:"] = "🎁",
  [":birthday:"] = "🎂",
  [":christmas_tree:"] = "🎄",
  [":santa:"] = "🎅",
  [":balloon:"] = "🎈",
  [":camera:"] = "📷",
  [":phone:"] = "📱",
  [":computer:"] = "💻",
  [":video_game:"] = "🎮",
  [":rocket:"] = "🚀",
  [":airplane:"] = "✈️",
  [":car:"] = "🚗",
  [":train:"] = "🚂",
  [":bus:"] = "🚌",
  [":bike:"] = "🚲",
  [":ambulance:"] = "🚑",
  [":police_car:"] = "🚓",
  [":taxi:"] = "🚕",
  [":stop_sign:"] = "🛑",
  [":construction:"] = "🚧",
  [":fuelpump:"] = "⛽",
  [":hospital:"] = "🏥",
  [":bank:"] = "🏦",
  [":hotel:"] = "🏨",
  [":school:"] = "🏫",
  [":church:"] = "⛪",
  [":mosque:"] = "🕌",
  [":synagogue:"] = "🕍",
  [":kaaba:"] = "🕋",
  [":fountain:"] = "⛲",
  [":tent:"] = "⛺",
  [":bridge_at_night:"] = "🌉",
  [":carousel_horse:"] = "🎠",
  [":ferris_wheel:"] = "🎡",
  [":roller_coaster:"] = "🎢",
  [":ship:"] = "🚢",
}

local function removePatternsFromString(content)
  local characters = {}
  for characterIndex = 1, #content do
    local character = string.sub(content, characterIndex, characterIndex)
    if specialSyntax[character] then
      table.insert(characters, "%")
    end
    table.insert(characters, character)
  end
  return table.concat(characters)
end

local function getPlayerNameSafe()
  if GetResourceState("gmt") == "started" then
    local name = exports["gmt"]:getPlayerName(GetPlayerServerId(PlayerId()))
    if name and type(name) == "string" then
      return name
    end
  end
  return GetPlayerName(PlayerId())
end

function containsMyName(args)
  local myName = string.lower(exports["gmt"]:getPlayerName(GetPlayerServerId(PlayerId())))
  local message = table.concat(args, " ", 2)
  message = string.lower(message)
  local pattern = "%f[%a]@?" .. myName .. "%f[^%w_]"
  if string.match(message, pattern) then
    return true
  end
  
  return false
end

local function getUserIdSafe()
  if GetResourceState("gmt") == "started" then
    local user_id = exports["gmt"]:getUserId()
    if user_id and type(user_id) == "number" then
      return user_id
    end
  end
  return -1
end

function containsMyPermID(args)
  local myName = string.lower(exports["gmt"]:getPlayerName(PlayerId()))
  local myPermID = tostring(getUserIdSafe())
  local message = table.concat(args, " ", 2)
  message = string.lower(message)
  local permIdPattern = myPermID
  if string.match(message, permIdPattern) then
    return true
  end
  
  return false
end

--deprecated, use chat:addMessage
AddEventHandler('chatMessage', function(author, color, text, msgType, modeName)
  if not hideChat then

    if text then
      for code, emoji in pairs(emojis) do
        text = text:gsub(code, emoji)
      end
    end

    local args = { text }
    if author ~= "" then
      table.insert(args, 1, author)
    end
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        msgType = msgType,
        color = color,
        multiline = true,
        args = args,
        transparent = isReducedOpacity,
        isMention = containsMyName(args),
        isPermMention = containsMyPermID(args),
        mode = modeName
      }
    })
    TriggerServerEvent('GMT:chatMessage', source, author, args, modeName)
  end
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      templateId = 'print',
      multiline = true,
      args = { msg },
      mode = '_global'
    }
  })
end)

local isChatActive = function()
  return chatInputActive
end
exports('isChatActive', isChatActive)

-- addMessage
local addMessage = function(message)
  if not hideChat then
    if type(message) == 'string' then
      message = {
        args = { message }
      }
    end

    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = message
    })
  end
end

exports('addMessage', addMessage)
AddEventHandler('chat:addMessage', addMessage)

-- addSuggestion
local addSuggestion = function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end

exports('addSuggestion', addSuggestion)
AddEventHandler('chat:addSuggestion', addSuggestion)

AddEventHandler('chat:addSuggestions', function(suggestions)
  for _, suggestion in ipairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = suggestion
    })
  end
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)
AddEventHandler('chat:addMode', function(mode)
  SendNUIMessage({
    type = 'ON_MODE_ADD',
    mode = mode
  })
end)

AddEventHandler('chat:removeMode', function(name)
  SendNUIMessage({
    type = 'ON_MODE_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:removeAllModes', function()
  SendNUIMessage({
    type = 'ON_MODE_REMOVE_ALL'
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    local r, g, b = 0, 0x99, 255

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', exports["gmt"]:getPlayerName(id), { r, g, b }, data.message, data.mode)
    end
  end

  cb('ok')
end)

local function refreshCommands()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()

    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
        if IsAceAllowed(('command.%s'):format(command.name)) and command.name ~= 'toggleChat' then
            table.insert(suggestions, {
                name = '/' .. command.name,
                help = ''
            })
        end
    end

    TriggerEvent('chat:addSuggestions', suggestions)
  end
end

local function refreshThemes()
  local themes = {}

  for resIdx = 0, GetNumResources() - 1 do
    local resource = GetResourceByFindIndex(resIdx)

    if GetResourceState(resource) == 'started' then
      local numThemes = GetNumResourceMetadata(resource, 'chat_theme')

      if numThemes > 0 then
        local themeName = GetResourceMetadata(resource, 'chat_theme')
        local themeData = json.decode(GetResourceMetadata(resource, 'chat_theme_extra') or 'null')

        if themeName and themeData then
          themeData.baseUrl = 'nui://' .. resource .. '/'
          themes[themeName] = themeData
        end
      end
    end
  end

  SendNUIMessage({
    type = 'ON_UPDATE_THEMES',
    themes = themes
  })
end

AddEventHandler('onClientResourceStart', function(resName)
  Wait(500)

  refreshCommands()
  refreshThemes()
end)

AddEventHandler('onClientResourceStop', function(resName)
  Wait(500)

  refreshCommands()
  refreshThemes()
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init')

  refreshCommands()
  refreshThemes()

  chatLoaded = true

  cb('ok')
end)

local CHAT_HIDE_STATES = {
  SHOW_WHEN_ACTIVE = 0,
  ALWAYS_SHOW = 1,
  ALWAYS_HIDE = 2
}

local chatHideState = CHAT_HIDE_STATES.SHOW_WHEN_ACTIVE
local isFirstHide = true

Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)

  local lastChatHideState = -1
  local origChatHideState = -1

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        if isFirstLoad then
          SendNUIMessage({
            type = 'ON_MODE_SET_GLOBAL'
          })
          isFirstLoad = false
        end

        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) then
        SetNuiFocus(true)

        chatInputActivating = false
      end
    end

    if chatLoaded then
      local forceHide = IsScreenFadedOut() or IsPauseMenuActive()
      local wasForceHide = false

      if chatHideState ~= CHAT_HIDE_STATES.ALWAYS_HIDE then
        if forceHide then
          origChatHideState = chatHideState
          chatHideState = CHAT_HIDE_STATES.ALWAYS_HIDE
        end
      elseif not forceHide and origChatHideState ~= -1 then
        chatHideState = origChatHideState
        origChatHideState = -1
        wasForceHide = true
      end

      if chatHideState ~= lastChatHideState then
        lastChatHideState = chatHideState

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          hideState = chatHideState,
          fromUserInteraction = not forceHide and not isFirstHide and not wasForceHide
        })

        isFirstHide = false
      end
    end
  end
end)

AddEventHandler("GMT:hideChat",function(flag)
  hideChat = flag
end)

AddEventHandler("GMT:chatReduceOpacity", function(flag)
  isReducedOpacity = flag
end)

AddEventHandler("onClientResourceStart", function(resourceName)
  if resourceName == "gmt" then
    isFirstLoad = true
  end
end)