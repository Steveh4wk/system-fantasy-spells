-- Stefano Luciano Corp
-- Sistema Globale Trasformazioni Umane
-- Funziona per tutte le creature (Vampire, Demogorgon, ecc.)

-- ==============================
-- FUNZIONE GLOBALE TORNA UMANO
-- ==============================
local function TransformToHuman()
    local playerId = PlayerId()
    
    -- Resetta tutti gli stati delle creature
    CreatureSystem.SetCreatureState('isVampire', false)
    CreatureSystem.SetCreatureState('isDemogorgon', false)
    
    -- Usa modello umano di default
    local model = 'mp_m_freemode_01'
    local hash = joaat(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
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
    SetMeleeWeaponDamageModifier(1.0)
    SetPedScale(playerPed, 1.0)
    
    -- Resetta componenti vestiti a default
    for i = 0, 11 do
        SetPedComponentVariation(playerPed, i, 0, 0, 0)
    end
    
    lib.notify({title = 'Fantasy Peds', description = 'Sei tornato umano!'})
    return true
end

-- ==============================
-- COMANDO UNIVERSALE TORNA UMANO
-- ==============================
RegisterCommand('human', function()
    TransformToHuman()
end)

-- ==============================
-- HANDLER TASTO O - TORNA UMANO (COME GUIDA TECNICA)
-- ==============================
CreateThread(function()
    while true do
        Wait(0)
        
        -- Controlla se il giocatore preme O (keycode 79)
        if IsControlJustPressed(0, 79) then
            -- Controlla se è trasformato in una creatura
            if CreatureSystem.GetCreatureState('isVampire') or CreatureSystem.GetCreatureState('isDemogorgon') then
                TransformToHuman()
            end
        end
    end
end)

-- ==============================
-- COMANDO DI EMERGENZA FORZATO CON DATABASE
-- ==============================
RegisterCommand('forcehuman', function()
    local playerPed = PlayerPedId()
    
    -- FORZA ASSOLUTO - resetta TUTTO
    print('[EMERGENCY] Forcing complete reset...')
    
    -- 1. Ferma TUTTI gli effetti possibili
    StopAllScreenEffects()
    StopScreenEffect("DrugsDrivingIn")
    StopScreenEffect("DeathFailOut")
    StopScreenEffect("ChopVision")
    StopScreenEffect("DrugsDrivingOut")
    StopScreenEffect("HeistTrip")
    StopScreenEffect("DrugsMichaelAliensFight")
    StopScreenEffect("DrugsTrevorClownsFight")
    StopScreenEffect("HeistCelebPass")
    StopScreenEffect("HeistCelebEnd")
    StopScreenEffect("HeistCelebFail")
    StopScreenEffect("MP_corona_switch")
    StopScreenEffect("RaceTurbo")
    StopScreenEffect("RaceTurboLap")
    StopScreenEffect("DefaultFlash")
    StopScreenEffect("BeastLaunch")
    StopScreenEffect("CamPushInNeutral")
    StopScreenEffect("CamPushIn")
    StopScreenEffect("CamPushOutNeutral")
    StopScreenEffect("CamPushOut")
    
    -- 2. Resetta TUTTI i modificatori
    SetNightvision(false)
    SetEntityAlpha(playerPed, 255, false)
    ResetPedMovementClipset(playerPed, 0.0)
    ResetPedStrafeClipset(playerPed)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetSwimMultiplierForPlayer(PlayerId(), 1.0)
    SetPedScale(playerPed, 1.0)
    
    -- 3. Resetta stati creature
    if CreatureSystem then
        CreatureSystem.SetCreatureState('isVampire', false)
        CreatureSystem.SetCreatureState('isDemogorgon', false)
    end
    
    -- 4. FORZA RIPRISTINO PERSONAGGIO COMPLETO DA DATABASE
    -- Prova con illenium appearance
    local success = pcall(function()
        exports['illenium-appearance']:ReloadPlayer()
    end)
    
    if success then
        Wait(1000)
        print('[EMERGENCY] Illenium reload successful')
    else
        -- Fallback: forza reload completo QB-Core
        local success2 = pcall(function()
            TriggerEvent('qb-clothing:client:loadPlayerClothing')
        end)
        
        if not success2 then
            -- Fallback finale: forza skin base e trigger reload
            local defaultModel = 'mp_m_freemode_01'
            local hash = joaat(defaultModel)
            
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end
            
            SetPlayerModel(PlayerId(), hash)
            SetModelAsNoLongerNeeded(hash)
            
            -- Attendi e forza trigger di reload skin
            Wait(500)
            TriggerEvent('skinchanger:loadSkin', 0)
            TriggerEvent('qb-clothes:client:loadOutfit')
        end
    end
    
    -- 5. Attendi e resetta finale
    Wait(1000)
    local newPed = PlayerPedId()
    
    -- 6. Cleanup finale completo
    ClearPedTasksImmediately(newPed)
    SetEntityHealth(newPed, 200)
    SetPedArmour(newPed, 0)
    ClearAllPedProps(newPed)
    
    -- Resetta tutti i componenti vestiti
    for i = 0, 11 do
        SetPedComponentVariation(newPed, i, 0, 0, 0)
    end
    
    -- 7. Notifica
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[EMERGENCY]", "RESET COMPLETO - Personaggio ripristinato dal database!"}
    })
    
    print('[EMERGENCY] Complete reset executed - character reloaded from database')
end)

-- ==============================
-- COMANDO DEBUG PER VEDERE STATO
-- ==============================
RegisterCommand('mystatus', function()
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)
    local health = GetEntityHealth(playerPed)
    local alpha = GetEntityAlpha(playerPed)
    
    print('[DEBUG] Model:', model)
    print('[DEBUG] Health:', health)
    print('[DEBUG] Alpha:', alpha)
    print('[DEBUG] Nightvision:', IsNightvisionActive())
    
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        multiline = true,
        args = {"[DEBUG]", "Model: " .. model .. " Health: " .. health .. " Alpha: " .. alpha}
    })
end)

-- ==============================
-- ESPORT FUNZIONE GLOBALE
-- ==============================
exports('TransformToHuman', TransformToHuman)
