game 'gta5'
fx_version 'cerulean'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

version '2.0.0'


shared_script 'shared/clientloader.lua'

server_scripts {
    'server/functions.lua',
    'server/main.lua'
}

client_script "@Badger-Anticheat/acloader.lua"