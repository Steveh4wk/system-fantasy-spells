-- Stefano Luciano Corp
-- Script client Vampiro + Menu Spell + Cooldown
-- Integra fantasy_spells per controllo razza e spell

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
            lib.notify({title = 'Vampiro', description = 'Visione di sangue attivata!'})
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
-- TRASFORMAZIONE VAMPIRO
-- ==============================
RegisterCommand('become_vampire', function()
    local playerId = PlayerId()

    if not isVampire() then
        exports['fantasy_peds']:SetCreatureState('isVampire', true)
        if lib and lib.notify then
            lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro!'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 100, 255},
                multiline = true,
                args = {"Fantasy Peds", "Sei diventato un Vampiro!"}
            })
        end
    end
    
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
            exports['fantasy_peds']:SetCreatureState('isDemogorgon', false)
            if lib and lib.notify then
                lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro!'})
            else
                TriggerEvent('chat:addMessage', {
                    color = {255, 100, 255},
                    multiline = true,
                    args = {"Fantasy Peds", "Sei diventato un Vampiro!"}
                })
            end
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
    if lib and lib.notify then
        lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro!'})
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 255},
            multiline = true,
            args = {"Fantasy Peds", "Sei diventato un Vampiro!"}
        })
    end
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

            -- Usa il modello Demogorgon reale (copia del Vampire)
            local model = 'Demogorgon'
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
            
            lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Demogorgon! 👹'})
        end
    }

    -- Opzione Spell Vampiro (solo se vampiro)
    if isVampire then
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
                -- Fallback se CreatureSystem non disponibile
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
                    lib.notify({title = 'Fantasy Peds', description = 'Sei tornato umano (fallback)!'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"Fantasy Peds", "Sei tornato umano (fallback)!"}
                    })
                end
            end
        end
    }

    lib.registerContext({
        id = 'creature_menu',
        title = '🌙 Menu Creature',
        options = options
    })

    lib.showContext('creature_menu')
end)

-- ==============================
-- TORNA UMANO (UNIFICATO)
-- ==============================
RegisterCommand('revert_all', function()
    if isVampire or isDemogorgon then
        local defaultModel = 'mp_m_freemode_01' -- Skin umana di default
        local hash = joaat(defaultModel)

        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end

        SetPlayerModel(PlayerId(), hash)
        SetModelAsNoLongerNeeded(hash)

        exports['fantasy_peds']:SetCreatureState('isVampire', false)
        exports['fantasy_peds']:SetCreatureState('isDemogorgon', false)
        lib.notify({title = 'Fantasy Peds', description = 'Sei tornato umano!'})
    end
end)

-- ==============================
-- MENU SPELL VAMPIRO
-- ==============================
RegisterCommand('vampire_spells', function()
    local playerId = PlayerId()

    -- Prova prima con export diretto
    local success, hasVampireState = pcall(function()
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
        return
    end
    
    -- Se l'export funziona, procedi normalmente
    if not hasVampireState then
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
