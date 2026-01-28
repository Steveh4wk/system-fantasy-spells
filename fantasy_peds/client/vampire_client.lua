-- Stefano Luciano Corp
-- Script client Vampiro + Menu Spell + Cooldown
-- Integra fantasy_spells per controllo razza e spell

-- Sistema di salvataggio stato originale
local originalPlayerState = {
    model = nil,
    hash = nil,
    components = {},
    props = {},
    saved = false
}

-- Stati delle creature
local creatureStates = {
    isVampire = false,
    isDemogorgon = false,
    isIceWolf = false
}

-- ==============================
-- SALVA STATO ORIGINALE
-- ==============================
local function SaveOriginalState()
    if not originalPlayerState.saved then
        local playerPed = PlayerPedId()
        originalPlayerState.model = GetEntityModel(playerPed)
        originalPlayerState.hash = joaat('mp_m_freemode_01') -- Default fallback
        
        -- Salva tutti i componenti
        for i = 0, 11 do
            originalPlayerState.components[i] = {
                drawable = GetPedDrawableVariation(playerPed, i),
                texture = GetPedTextureVariation(playerPed, i),
                palette = GetPedPaletteVariation(playerPed, i)
            }
        end
        
        -- Salva tutti i props
        for i = 0, 7 do
            originalPlayerState.props[i] = {
                prop = GetPedPropIndex(playerPed, i),
                texture = GetPedPropTextureIndex(playerPed, i)
            }
        end
        
        originalPlayerState.saved = true
        print('[DEBUG] Original player state saved')
    end
end

-- ==============================
-- CLEANUP TRASFORMAZIONE
-- ==============================
local function CleanupTransformation()
    -- Chiudi tutti i menu ox_lib attivi
    lib.hideContext()
    
    -- Interrompi tutte le animazioni attive
    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    
    -- Resetta effetti visivi
    SetNightvision(false)
    SetEntityAlpha(playerPed, 255, false)
    
    -- Rimuovi tutti i clipset applicati
    ResetPedMovementClipset(playerPed, 0.0)
    ResetPedStrafeClipset(playerPed)
    
    -- Ferma eventuali screen effects
    StopAllScreenEffects()
    
    -- Resetta modificatori di gioco
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetMeleeWeaponDamageModifier(1.0)
    
    print('[DEBUG] Transformation cleanup completed')
end

-- ==============================
-- RIPRISTINA STATO ORIGINALE
-- ==============================
local function RestoreOriginalState()
    if originalPlayerState.saved then
        -- Prima fai cleanup di tutto
        CleanupTransformation()
        
        local playerId = PlayerId()
        
        -- Carica il modello originale
        RequestModel(originalPlayerState.hash)
        while not HasModelLoaded(originalPlayerState.hash) do
            Wait(10)
        end
        
        SetPlayerModel(playerId, originalPlayerState.hash)
        SetModelAsNoLongerNeeded(originalPlayerState.hash)
        
        Wait(500) -- Aspetta che il modello si carichi completamente
        
        local playerPed = PlayerPedId()
        
        -- Ripristina tutti i componenti
        for i = 0, 11 do
            local comp = originalPlayerState.components[i]
            if comp.drawable ~= -1 then
                SetPedComponentVariation(playerPed, i, comp.drawable, comp.texture, comp.palette)
            end
        end
        
        -- Ripristina tutti i props
        for i = 0, 7 do
            local prop = originalPlayerState.props[i]
            if prop.prop ~= -1 then
                SetPedPropIndex(playerPed, i, prop.prop, prop.texture, true)
            end
        end
        
        -- Resetta tutti gli stati delle creature
        creatureStates.isVampire = false
        creatureStates.isDemogorgon = false
        creatureStates.isIceWolf = false
        
        print('[DEBUG] Original player state restored')
        return true
    end
    return false
end

-- ==============================
-- GETTER/SETTER STATI
-- ==============================
local function SetCreatureState(creature, state)
    if creatureStates[creature] ~= nil then
        creatureStates[creature] = state
    end
end

local function GetCreatureState(creature)
    return creatureStates[creature] or false
end

local function IsAnyCreatureActive()
    for _, state in pairs(creatureStates) do
        if state then return true end
    end
    return false
end

-- ==============================
-- INIZIALIZAZIONE AUTOMATICA
-- ==============================
CreateThread(function()
    Wait(2000) -- Aspetta che il giocatore sia completamente caricato
    SaveOriginalState()
end)

local spellCooldowns = {}                 -- Tieni traccia dei cooldown delle spell

-- ==============================
-- LISTA SPELL VAMPIRO
-- ==============================
local vampireSpells = {
    bloodvision = {
        label = "Visione di Sangue",
        cooldown = 30,                    -- in secondi
        action = function()
            SetNightvision(true)
            if lib and lib.notify then
                lib.notify({title = 'Vampiro', description = 'Visione di sangue attivata!'})
            else
                TriggerEvent('chat:addMessage', {
                    color = {255, 100, 255},
                    multiline = true,
                    args = {"Vampiro", "Visione di sangue attivata!"}
                })
            end
        end
    }
}

-- ==============================
-- LISTA SPELL LYCAN
-- ==============================
local lycanSpells = {
    howl = {
        label = "Ululato",
        cooldown = 60,                    -- in secondi
        action = function()
            -- Effetto ululato: aumenta velocità temporaneamente
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.5)
            SetMeleeWeaponDamageModifier(1.5)
            if lib and lib.notify then
                lib.notify({title = 'Lycan', description = 'Ululato attivato! Velocità aumentata!'})
            else
                TriggerEvent('chat:addMessage', {
                    color = {100, 255, 100},
                    multiline = true,
                    args = {"Lycan", "Ululato attivato! Velocità aumentata!"}
                })
            end
            -- Resetta dopo 30 secondi
            CreateThread(function()
                Wait(30000)
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                SetMeleeWeaponDamageModifier(1.0)
                if lib and lib.notify then
                    lib.notify({title = 'Lycan', description = 'Effetto ululato terminato'})
                end
            end)
        end
    }
}

-- ==============================
-- FUNZIONI COOLDOWN
-- ==============================
local function IsOnCooldown(spellId)
    return spellCooldowns[spellId] and spellCooldowns[spellId] > GetGameTimer()
end

local function StartCooldown(spellId, timeSec)
    spellCooldowns[spellId] = GetGameTimer() + (timeSec * 1000)
end

-- ==============================
-- GETTER STATO VAMPIRO
-- ==============================
local function isVampire()
    return exports['fantasy_peds']:GetCreatureState('isVampire')
end

-- ==============================
-- GETTER STATO LYCAN
-- ==============================
local function isLycan()
    return exports['fantasy_peds']:GetCreatureState('isIceWolf')
end

-- ==============================
-- TRASFORMAZIONE VAMPIRO
-- ==============================
RegisterCommand('become_vampire', function()
    exports['fantasy_peds']:RequestTransformation('vampire')
end)

-- ==============================
-- MENU CREATURE (EVENTO ESTERNO)
-- ==============================
RegisterNetEvent('fantasy_peds:client:openCreatureMenu', function()
    TriggerEvent('creatures') -- Chiama il comando creatures esistente
end)

-- ==============================
-- MENU CREATURE
-- ==============================
RegisterCommand('creatures', function()
    local options = {}

    -- Opzione Vampiro
    options[#options+1] = {
        title = '🧛‍♂️ Diventa Vampiro',
        description = 'Trasformati in un vampiro oscuro',
        onSelect = function()
            -- Chiama direttamente la logica del comando become_vampire
            local playerId = PlayerId()

            -- Prova prima con export diretto
            local success, hasVampire = pcall(function()
                return exports['fantasy_spells']:HasVampire(playerId)
            end)
            
            -- Se l'export fallisce, usa evento come fallback
            if not success then
                TriggerServerEvent('fantasy_spells:server:CheckVampire')
                
                local eventHandler = nil
                eventHandler = AddEventHandler('fantasy_spells:client:VampireCheckResult', function(isVampire)
                    if eventHandler then
                        RemoveEventHandler(eventHandler)
                    end
                    
                    if not isVampire then
                        local success2, result = pcall(function()
                            return exports['fantasy_spells']:UnlockVampire(playerId)
                        end)
                        if not success2 then
                            print('[ERROR] UnlockVampire export failed, using event fallback')
                            TriggerServerEvent('fantasy_spells:server:UnlockVampire')
                        end
                    end

                    local model = 'Vampire'
                    local hash = joaat(model)

                    RequestModel(hash)
                    while not HasModelLoaded(hash) do
                        Wait(10)
                    end

                    SetPlayerModel(playerId, hash)
                    SetModelAsNoLongerNeeded(hash)

                    exports['fantasy_peds']:SetCreatureState('isVampire', true)
                    lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro!'})
                end)
                return
            end
            
            -- Se l'export funziona, procedi normalmente
            if not hasVampire then
                local success2, result = pcall(function()
                    return exports['fantasy_spells']:UnlockVampire(playerId)
                end)
                if not success2 then
                    print('[ERROR] UnlockVampire export failed, using event fallback')
                    TriggerServerEvent('fantasy_spells:server:UnlockVampire')
                end
            end

            local model = 'Vampire'
            local hash = joaat(model)

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end

            SetPlayerModel(playerId, hash)
            SetModelAsNoLongerNeeded(hash)

            exports['fantasy_peds']:SetCreatureState('isVampire', true)
            lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro!'})
        end
    }

    -- Opzione Demogorgon
    options[#options+1] = {
        title = '👹 Diventa Demogorgon',
        description = 'Trasformati nel mostro dell\'Upside Down',
        onSelect = function()
            -- Chiama direttamente la logica del comando become_demogorgon
            local playerId = PlayerId()

            -- Usa il modello Vampire per evitare crash (Demogorgon potrebbe essere corrotto)
            local model = 'Vampire'
            local hash = joaat(model)

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end

            SetPlayerModel(playerId, hash)
            SetModelAsNoLongerNeeded(hash)

            -- Applica effetti visivi per sembrare un Demogorgon
            local playerPed = PlayerPedId()

            -- Rendi più scuro ma visibile
            SetEntityAlpha(playerPed, 220, false)

            -- Effetto visivo di trasformazione
            StartScreenEffect("DeathFailOut", 2000, false)

            exports['fantasy_peds']:SetCreatureState('isDemogorgon', true)
            lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Demogorgon! 👹'})
        end
    }

    -- Opzione Ice Wolf
    options[#options+1] = {
        title = '🐺 Diventa Ice Wolf',
        description = 'Trasformati in un lupo di ghiaccio leggendario',
        onSelect = function()
            -- Chiama direttamente la logica del comando become_ice_wolf
            local playerId = PlayerId()

            -- Prova prima con export diretto per lycan/werewolf
            local success, hasWerewolf = pcall(function()
                return exports['fantasy_spells']:HasWerewolf(playerId)
            end)

            -- Se l'export fallisce, usa evento come fallback
            if not success then
                TriggerServerEvent('fantasy_spells:server:CheckWerewolf')

                local eventHandler = nil
                eventHandler = AddEventHandler('fantasy_spells:client:WerewolfCheckResult', function(isWerewolf)
                    if eventHandler then
                        RemoveEventHandler(eventHandler)
                    end

                    if not isWerewolf then
                        local success2, result = pcall(function()
                            return exports['fantasy_spells']:UnlockWerewolf(playerId)
                        end)
                        if not success2 then
                            print('[ERROR] UnlockWerewolf export failed, using event fallback')
                            TriggerServerEvent('fantasy_spells:server:UnlockWerewolf')
                        end
                    end

                    local model = 'Ice Wolf'
                    local hash = joaat(model)

                    RequestModel(hash)
                    while not HasModelLoaded(hash) do
                        Wait(10)
                    end

                    SetPlayerModel(playerId, hash)
                    SetModelAsNoLongerNeeded(hash)

                    -- Effetti visivi per Ice Wolf
                    local playerPed = PlayerPedId()

                    -- Effetto visivo di trasformazione con gelo
                    StartScreenEffect("DeathFailOut", 2000, false)

                    -- Aumenta leggermente la velocità base
                    SetRunSprintMultiplierForPlayer(playerId, 1.2)

                    exports['fantasy_peds']:SetCreatureState('isIceWolf', true)
                    lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Ice Wolf! 🐺'})
                end)
                return
            end

            -- Se l'export funziona, procedi normalmente
            if not hasWerewolf then
                local success2, result = pcall(function()
                    return exports['fantasy_spells']:UnlockWerewolf(playerId)
                end)
                if not success2 then
                    print('[ERROR] UnlockWerewolf export failed, using event fallback')
                    TriggerServerEvent('fantasy_spells:server:UnlockWerewolf')
                end
            end

            local model = 'Ice Wolf'
            local hash = joaat(model)

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end

            SetPlayerModel(playerId, hash)
            SetModelAsNoLongerNeeded(hash)

            -- Effetti visivi per Ice Wolf
            local playerPed = PlayerPedId()

            -- Effetto visivo di trasformazione con gelo
            StartScreenEffect("DeathFailOut", 2000, false)

            -- Aumenta leggermente la velocità base
            SetRunSprintMultiplierForPlayer(playerId, 1.2)

            exports['fantasy_peds']:SetCreatureState('isIceWolf', true)
            lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Ice Wolf! 🐺'})
        end
    }

    -- Opzione Spell Vampiro (solo se vampiro)
    if isVampire() then
        options[#options+1] = {
            title = '📖 Grimorio Vampiro',
            description = 'Accedi alle spell vampiro',
            onSelect = function()
                -- Chiama direttamente la logica del comando vampire_spells
                local options = {}

                for spellId, spell in pairs(vampireSpells) do
                    options[#options+1] = {
                        title = spell.label,
                        onSelect = function()
                            if not IsOnCooldown(spellId) then
                                spell.action()
                                StartCooldown(spellId, spell.cooldown)
                            else
                                if lib and lib.notify then
                                    lib.notify({title='Vampiro', description='Spell in cooldown!', type='error'})
                                else
                                    TriggerEvent('chat:addMessage', {
                                        color = {255, 0, 0},
                                        multiline = true,
                                        args = {"Vampiro", "Spell in cooldown!"}
                                    })
                                end
                            end
                        end
                    }
                end

                if lib and lib.registerContext then
                    lib.registerContext({
                        id = 'vampire_spell_menu',
                        title = 'Grimorio Vampiro',
                        options = options
                    })
                    lib.showContext('vampire_spell_menu')
                else
                    -- Fallback se ox_lib non disponibile
                    TriggerEvent('chat:addMessage', {
                        color = {255, 100, 255},
                        multiline = true,
                        args = {"Vampiro", "Menu spell non disponibile - usa /vampire_spells"}
                    })
                end
            end
        }
    end

    -- Opzione Spell Lycan (solo se lycan)
    if isLycan() then
        options[#options+1] = {
            title = '📖 Libro delle Bestie',
            description = 'Accedi alle abilità lycan',
            onSelect = function()
                local options = {}

                for spellId, spell in pairs(lycanSpells) do
                    options[#options+1] = {
                        title = spell.label,
                        onSelect = function()
                            if not IsOnCooldown(spellId) then
                                spell.action()
                                StartCooldown(spellId, spell.cooldown)
                            else
                                if lib and lib.notify then
                                    lib.notify({title='Lycan', description='Abilità in cooldown!', type='error'})
                                else
                                    TriggerEvent('chat:addMessage', {
                                        color = {255, 0, 0},
                                        multiline = true,
                                        args = {"Lycan", "Abilità in cooldown!"}
                                    })
                                end
                            end
                        end
                    }
                end

                if lib and lib.registerContext then
                    lib.registerContext({
                        id = 'lycan_spell_menu',
                        title = 'Libro delle Bestie',
                        options = options
                    })
                    lib.showContext('lycan_spell_menu')
                else
                    -- Fallback se ox_lib non disponibile
                    TriggerEvent('chat:addMessage', {
                        color = {100, 255, 100},
                        multiline = true,
                        args = {"Lycan", "Menu abilità non disponibile"}
                    })
                end
            end
        }
    end

    -- Opzione torna umano
    options[#options+1] = {
        title = '👤 Torna Umano',
        description = 'Ritorna al tuo stato originale completo',
        onSelect = function()
            if exports['fantasy_peds']:RestoreOriginalState() then
                exports['fantasy_peds']:ResetCreatures()
                if lib and lib.notify then
                    lib.notify({title = 'Fantasy Peds', description = 'Sei tornato al tuo stato originale!'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"Fantasy Peds", "Sei tornato al tuo stato originale!"}
                    })
                end
            else
                -- Fallback sicuro
                local defaultModel = 'mp_m_freemode_01'
                local hash = joaat(defaultModel)

                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Wait(10)
                end

                SetPlayerModel(PlayerId(), hash)
                SetModelAsNoLongerNeeded(hash)

                exports['fantasy_peds']:ResetCreatures()
                if lib and lib.notify then
                    lib.notify({title = 'Fantasy Peds', description = 'Fallback umano applicato'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"Fantasy Peds", "Fallback umano applicato"}
                    })
                end
            end
        end
    }

    if lib and lib.registerContext then
        lib.registerContext({
            id = 'creature_menu',
            title = '🌙 Menu Creature',
            options = options
        })
        lib.showContext('creature_menu')
    else
        -- Fallback se ox_lib non disponibile
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"Creature", "Menu non disponibile - usa /become_vampire o /become_demogorgon"}
        })
    end
end)

-- ==============================
-- MENU SPELL VAMPIRO
-- ==============================
RegisterCommand('vampire_spells', function()
    local playerId = PlayerId()

    -- Prova prima con export diretto
    local success, isVampire = pcall(function()
        return exports['fantasy_spells']:HasVampire(playerId)
    end)
    
    -- Se l'export fallisce, usa evento come fallback
    if not success then
        TriggerServerEvent('fantasy_spells:server:CheckVampire')
        
        local eventHandler = nil
        eventHandler = AddEventHandler('fantasy_spells:client:VampireCheckResult', function(isVampire)
            if eventHandler then
                RemoveEventHandler(eventHandler)
            end
            
            if not isVampire then
                if lib and lib.notify then
                    lib.notify({title='Vampiro', description='Non sei un Vampiro!', type='error'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Vampiro", "Non sei un Vampiro!"}
                    })
                end
                return
            end

            local options = {}

            for spellId, spell in pairs(vampireSpells) do
                options[#options+1] = {
                    title = spell.label,
                    onSelect = function()
                        if not IsOnCooldown(spellId) then
                            spell.action()
                            StartCooldown(spellId, spell.cooldown)
                        else
                            lib.notify({title='Vampiro', description='Spell in cooldown!', type='error'})
                        end
                    end
                }
            end

            lib.registerContext({
                id = 'vampire_spell_menu',
                title = 'Grimorio Vampiro',
                options = options
            })

            lib.showContext('vampire_spell_menu')
        end)
        return
    end
    
    -- Se l'export funziona, procedi normalmente
    if not isVampire then
        lib.notify({title='Vampiro', description='Non sei un Vampiro!', type='error'})
        return
    end

    local options = {}

    for spellId, spell in pairs(vampireSpells) do
        options[#options+1] = {
            title = spell.label,
            onSelect = function()
                if not IsOnCooldown(spellId) then
                    spell.action()
                    StartCooldown(spellId, spell.cooldown)
                else
                    lib.notify({title='Vampiro', description='Spell in cooldown!', type='error'})
                end
            end
        }
    end

    lib.registerContext({
        id = 'vampire_spell_menu',
        title = 'Grimorio Vampiro',
        options = options
    })

    lib.showContext('vampire_spell_menu')
end)

-- ==============================
-- ESPORT STATI
-- ==============================
exports('IsVampire', function()
    return exports['fantasy_peds']:GetCreatureState('isVampire')
end)

exports('IsLycan', function()
    return exports['fantasy_peds']:GetCreatureState('isIceWolf')
end)
