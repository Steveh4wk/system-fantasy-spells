fx_version 'cerulean'
game 'gta5'

author 'Stefano Luciano Corp'
description 'Fantasy system: races, skills, spells and transformations'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/skills.lua',
    'shared/spells.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/exports.lua'
}

client_scripts {
    'client/cooldown.lua',
    'client/spells.lua',
    'client/animagus.lua',
    'client/events.lua'
}
