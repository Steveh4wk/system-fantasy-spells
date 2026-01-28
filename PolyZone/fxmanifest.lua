fx_version 'cerulean'
game 'gta5'

author 'FiveM Server'
description 'PolyZone System'
version '1.0.0'

-- Client scripts
client_scripts {
    'client.lua'
}

-- Server scripts  
server_scripts {
    'server.lua'
}

-- Dependencies
dependencies {
    'oxmysql'
}

shared_scripts {
    'config.lua'
}
