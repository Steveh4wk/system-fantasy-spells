-- fxmanifest.lua
-- Stefano Luciano Corp
-- Fantasy UI - Menu spell e gestione cooldown
fx_version 'cerulean'
game 'gta5'

author 'Stefano Luciano Corp'
description 'Fantasy UI - Menu spell e cooldown integrato con fantasy_spells'
version '1.0.0'

-- ==============================
-- SCRIPT CLIENT
-- ==============================
client_scripts {
    '@ox_lib/init.lua',    -- Inizializza ox_lib per menu e notifiche
    'client/events.lua',
    'client/cooldown.lua', -- Gestione cooldown spell
    'client/menu.lua'      -- Menu spell Vampiro e Animagus
}
