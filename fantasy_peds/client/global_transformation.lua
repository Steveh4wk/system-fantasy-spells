--- Stefano Luciano Corp
-- Sistema Globale Trasformazioni Umane - VERSIONE CORRETTA
-- Funziona per tutte le creature (Vampire, Demogorgon, Ice Wolf)

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

-- ==============================
-- FUNZIONE GLOBALE TORNA UMANO
-- ==============================
local function TransformToHuman()
    local playerId = PlayerId()
    
    -- Resetta tutti gli stati delle creature
    if CreatureSystem and CreatureSystem.SetCreatureState then
        CreatureSystem.SetCreatureState('isVampire', false)
        CreatureSystem.SetCreatureState('isDemogorgon', false)
        CreatureSystem.SetCreatureState('isIceWolf', false)
    end
    
    -- Usa modello umano di default in modo sicuro
    local hash = LoadModelSafe('mp_m_freemode_01')
    if not hash then
        print('[ERROR] Impossibile caricare modello umano')
        return false
    end

    SetPlayerModel(playerId, hash)
    SetModelAsNoLongerNeeded(hash)

    -- Resetta tutti gli effetti visivi
    local playerPed = PlayerPedId()
    SetEntityAlpha(playerPed, 255, false)
    ResetPedMovementClipset(playerPed, 0.0)
    ResetPedStrafeClipset(playerPed)
    StopAllScreenEffects()
    SetNightvision(false)
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
    SetPlayerMeleeWeaponDamageModifier(playerId, 1.0)
    SetPedScale(playerPed, 1.0)
    
    -- Resetta componenti vestiti a default
    for i = 0, 11 do
        SetPedComponentVariation(playerPed, i, 0, 0, 0)
    end
    
    if lib and lib.notify then
        lib.notify({title = 'Fantasy Peds', description = 'Sei tornato umano!'})
    else
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Fantasy Peds", "Sei tornato umano!"}
        })
    end
    return true
end

-- ==============================
-- ESPORTAZIONE OBBLIGATORIA - BUG CRITICO FIXATO
-- ==============================
exports('TransformToHuman', TransformToHuman)
exports('RestoreOriginalState', TransformToHuman) -- Alias per compatibilità

-- ==============================
-- COMANDO UNIVERSALE TORNA UMANO
-- ==============================
RegisterCommand('human', function()
    CreateThread(function()
        TransformToHuman()
    end)
end)

print('[INFO] Global transformation script loaded - FIXED VERSION')
