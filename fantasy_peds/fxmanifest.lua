-- ==========================================================
-- FXManifest per Fantasy Peds
-- Autore: Stefano Luciano Corp
-- Gestione Vampiri, Lycans e Animali
-- ==========================================================

fx_version 'cerulean'
game 'gta5'

author 'Stefano Luciano Corp'
description 'Fantasy Peds: Vampiri, Lycans, Feeding e Animali'
version '1.0.0'

-- ==========================================================
-- Dependencies
-- ==========================================================
dependencies {
    'ox_inventory',
    'ox_target'
}

-- ==========================================================
-- Client Scripts
-- ==========================================================
client_scripts {
    '@ox_lib/init.lua',               -- librerie comuni
    'client/fantasy_feeding.lua',     -- gestione feeding animali, target, acqua
    'client/vampire_client.lua',      -- gestione Vampiro (trasformazione + feeding)
    'client/lycan_client.lua',        -- gestione Lycan (trasformazione + feeding)
    'client/fantasy_creatures_client.lua', -- menu creatures completo
    'client/feeding_interaction.lua'  -- sistema pulsante feeding prossimità
}

-- ==========================================================
-- Shared / Config
-- ==========================================================
shared_scripts {
    'items.lua'                        -- items Vampiro/Lycan
}

-- ==========================================================
-- Data Files / Streaming
-- ==========================================================
data_file 'PED_METADATA_FILE' 'stream/Vampire/peds.meta'
data_file 'PED_METADATA_FILE' 'stream/Lycan/peds.meta'

files {
    'stream/Vampire/Vampire.ydd',
    'stream/Vampire/Vampire.yft',
    'stream/Vampire/Vampire.yld',
    'stream/Vampire/Vampire.ymt',
    'stream/Vampire/Vampire.ytd',
    'stream/Vampire/peds.meta',
    'stream/Lycan/icewolf.ydd',
    'stream/Lycan/icewolf.yft',
    'stream/Lycan/icewolf.ymt',
    'stream/Lycan/icewolf.ytd',
    'stream/Lycan/peds.meta'
}

-- ==========================================================
-- Exports
-- ==========================================================
exports {
    'IsVampire',
    'IsLycan',
    'SetPlayerState',
    'AddHunger',
    'AddThirst',
    'KillAnimalProperly'
}
