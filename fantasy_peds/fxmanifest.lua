fx_version 'cerulean'
game 'gta5'

files {
    'stream/**/peds.meta'
}

data_file 'PED_METADATA_FILE' 'stream/**/peds.meta'

dependencies {
    'ox_lib',
    'qb-core'
}

server_scripts {
    '@qb-core/import.lua',
    'server/creatures.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/init.lua',
    'client/events.lua',
    'client/creature_cooldown.lua',
    'client/transformation_handler.lua',
    'client/global_transformation.lua',
    'client/vampire_client.lua',
    'client/demogorgon_client.lua',
    'client/backup vamp.lua'
}

shared_scripts {
    'shared/creature_system.lua'
}
