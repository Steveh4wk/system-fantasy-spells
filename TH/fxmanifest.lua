-- Resource Metadata
fx_version 'bodacious'
games { 'gta5' }

author 'stefanolucianocorp' --for astral rp
description 'TakeHostage For QBCore'
version '2.0.0'

dependency 'qb-core'

shared_scripts {
    'config.lua'
}

client_script {
    'client/cl_takehostage.lua',
    'spawn_weapon.lua'
}
server_script {
    'server/sv_takehostage.lua'
}
