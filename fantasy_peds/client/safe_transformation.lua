-- Stefano Luciano Corp
-- Sistema di fallback sicuro per trasformazioni - VERSIONE CORRETTA
-- TUTTE LE TRASFORMAZIONI SONO THREAD-SAFE

-- Sistema di caricamento modelli sicuro
local function LoadModelSafe(model)
    local hash = joaat(model)

    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print('[ERROR] Modello non valido:', model)
        return false
    end

    RequestModel(hash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            print('[ERROR] Timeout caricamento modello:', model)
            return false
        end
        Wait(10)
    end

    return hash
end

-- Modelli di fallback FiveM nativi
local FALLBACK_MODELS = {
    vampire = 'u_m_y_rsranger_01',      -- Ranger come fallback vampiro
    demogorgon = 'u_m_y_zombie_01',      -- Zombie come fallback demogorgon  
    icewolf = 'a_c_wolf',               -- Lupo nativo come fallback ice wolf
    ice_wolf = 'a_c_wolf'               -- Lupo nativo come fallback ice wolf
}

-- Modelli originali da tentare prima
local ORIGINAL_MODELS = {
    vampire = 'Vampire',
    demogorgon = 'Demogorgon',
    icewolf = 'icewolf',
    ice_wolf = 'icewolf'
}

-- ==============================
-- FUNZIONE SICURA CARICAMENTO MODELLO
-- ==============================
local function SafeLoadModel(creatureType, callback)
    local originalModel = ORIGINAL_MODELS[creatureType]
    local fallbackModel = FALLBACK_MODELS[creatureType]
    
    if not originalModel or not fallbackModel then
        print('[ERROR] Creature type non riconosciuto:', creatureType)
        if callback then callback(false, nil) end
        return
    end
    
    -- Tenta prima con il modello originale
    local originalHash = LoadModelSafe(originalModel)
    
    if originalHash then
        print(string.format('[SAFE] ✅ %s caricato con successo!', originalModel))
        if callback then callback(true, originalHash) end
        return
    end
    
    -- Fallback al modello nativo
    print(string.format('[SAFE] Uso fallback %s per %s', fallbackModel, creatureType))
    local fallbackHash = LoadModelSafe(fallbackModel)
    
    if fallbackHash then
        print(string.format('[SAFE] ✅ Fallback %s caricato!', fallbackModel))
        if callback then callback(true, fallbackHash) end
    else
        print(string.format('[SAFE] ❌ Nessun modello disponibile per %s', creatureType))
        if callback then callback(false, nil) end
    end
end

-- ==============================
-- ESPORTAZIONE FUNZIONE SICURA
-- ==============================
exports('SafeLoadModel', SafeLoadModel)

-- ==============================
-- TRASFORMAZIONI SICURE - THREAD-SAFE
-- ==============================
RegisterNetEvent('fantasy_peds:client:safeTransform', function(creatureType)
    CreateThread(function()
        local playerId = PlayerId()
        
        -- Cleanup prima della trasformazione
        if lib and lib.hideContext then
            lib.hideContext()
        end
        
        local playerPed = PlayerPedId()
        ClearPedTasksImmediately(playerPed)
        StopAllScreenEffects()
        
        SafeLoadModel(creatureType, function(success, modelHash)
            if success and modelHash then
                SetPlayerModel(playerId, modelHash)
                SetModelAsNoLongerNeeded(modelHash)
                
                -- Aggiorna stato
                local stateKey = 'is' .. creatureType:gsub("^%l", string.upper)
                if creatureType == 'ice_wolf' then stateKey = 'isIceWolf' end
                if creatureType == 'icewolf' then stateKey = 'isIceWolf' end
                
                if exports['fantasy_peds'] and exports['fantasy_peds'].SetCreatureState then
                    exports['fantasy_peds']:SetCreatureState(stateKey, true)
                end
                
                -- Effetti visivi base
                playerPed = PlayerPedId()
                StartScreenEffect("DeathFailOut", 1500, false)
                
                if lib and lib.notify then
                    lib.notify({title = 'Fantasy Peds', description = 'Trasformato in ' .. creatureType .. '!'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {100, 255, 100},
                        multiline = true,
                        args = {"Fantasy Peds", "Trasformato in " .. creatureType .. "!"}
                    })
                end
                
                print(string.format('[SAFE] Trasformazione %s completata', creatureType))
            else
                if lib and lib.notify then
                    lib.notify({title = 'Errore', description = 'Impossibile trasformarsi in ' .. creatureType, type = 'error'})
                else
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Errore", "Impossibile trasformarsi in " .. creatureType}
                    })
                end
            end
        end)
    end)
end)

print('[SAFE] Safe transformation system loaded - FIXED VERSION')
