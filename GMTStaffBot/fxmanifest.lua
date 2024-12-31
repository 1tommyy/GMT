fx_version 'cerulean'
games { 'gta5' }
author 'GMT'
description 'This is a discord bot made by SERIO.'

server_only 'yes'

dependency 'gmt'

server_scripts {
    "@gmt/util/server/utils.lua",
    "bot.js"
}

server_exports {
    'dmUser',
}
client_script "@Badger-Anticheat/acloader.lua"