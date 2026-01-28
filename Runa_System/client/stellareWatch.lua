-- Stefano Luciano Corp. Dev - Orologio Stellare System
-- Integrato in Runa_System

local stellareActive = false

-- Funzione di reset completo per ESX
local function FullHealthReset()
    local ped = PlayerPedId()

    -- Reset vita al 100% invece che al 50%
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100) -- Dai anche armatura completa

    -- Stop bleeding / damage
    ClearPedBloodDamage(ped)
    ClearPedLastDamageBone(ped)
    ClearPedTasksImmediately(ped)

    -- Reset stati di movimento
    ResetPedMovementClipset(ped, 0.0)

    -- Invincibilità temporanea più lunga
    SetEntityInvincible(ped, true)

    -- Rimuove ragdoll forzato
    SetPedCanRagdoll(ped, true)

    -- Rimuovi invincibilità dopo 5 secondi (più sicuro)
    SetTimeout(5000, function()
        SetEntityInvincible(ped, false)
    end)
end

-- Funzione per effetti di fumo visibili a tutti
local function CreateSmokeEffects()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- Crea fumo visibile a tutti i player
    for i = 1, 5 do
        local offsetX = (i - 3) * 2.0 -- Posizioni diverse
        UseParticleFxAssetNextCall('core')
        local smoke = StartParticleFxLoopedAtCoord(
            'exp_grd_grenade_smoke',
            coords.x + offsetX,
            coords.y,
            coords.z,
            0.0, 0.0, 0.0,
            3.0, -- Scala più grande
            false, false, false, false
        )

        -- Rimuovi il fumo dopo 8 secondi
        SetTimeout(8000, function()
            StopParticleFxLooped(smoke, false)
        end)
    end

    -- Aggiungi particelle extra per effetto più intenso
    UseParticleFxAssetNextCall('core')
    local spark = StartParticleFxLoopedAtCoord(
        'ent_amb_falling_sparks',
        coords.x,
        coords.y,
        coords.z + 1.0,
        0.0, 0.0, 0.0,
        2.0,
        false, false, false, false
    )

    SetTimeout(8000, function()
        StopParticleFxLooped(spark, false)
    end)
end

-- Evento principale per la morte
RegisterNetEvent('QBCore:Client:OnPlayerDeath', function()
    if stellareActive then 
        return 
    end

    -- Imposta subito active per prevenire loop
    stellareActive = true

    -- Chiedi al server di usare l'orologio (diretto senza QBCore)
    TriggerServerEvent('stellare:useWatch')
end)

-- Ricevi risposta dal server
RegisterNetEvent('stellare:watchResult')
AddEventHandler('stellare:watchResult', function(success)
    if not success then return end

    stellareActive = true

    -- Attesa di sicurezza
    Wait(200)

    -- Effetti di fumo visibili a tutti
    CreateSmokeEffects()

    -- Effetto SOLO per il player
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'showStellare',
        sound = true
    })

    -- Tempo cinematico (7 secondi)
    Wait(7000)

    -- Revive
    TriggerEvent('hospital:client:Revive')

    Wait(500) -- lascia finire il revive
    FullHealthReset()

    -- Chiudi effetto
    SendNUIMessage({ action = 'hideStellare' })
    SetNuiFocus(false, false)

    -- Reset
    Wait(1000)
    stellareActive = false
end)

-- Monitoraggio continuo dello stato di morte
local function startDeathMonitoring()
    CreateThread(function()
        while true do
            Wait(1000) -- Controlla ogni secondo

            -- Prova diversi metodi per controllare la morte
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local isDead1 = LocalPlayer.state.dead
            local isDead2 = health <= 0

            -- Se il player è morto e non è già in revival (usa health come fallback)
            local isDead = isDead1 or isDead2
            if isDead and not stellareActive then
                -- Controlla se ha l'orologio
                local count = exports.ox_inventory:Search('count', 'orologiostellare')
                
                if count and count > 0 then
                    -- Attiva l'orologio automaticamente
                    TriggerEvent('QBCore:Client:OnPlayerDeath')
                end
            end
        end
    end)
end

-- Aggiungi anche evento di morte diretto come backup
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local ped = PlayerPedId()
        
        if victim == ped then
            local health = GetEntityHealth(ped)
            if health <= 0 and not stellareActive then
                -- Controlla se ha l'orologio
                local count = exports.ox_inventory:Search('count', 'orologiostellare')
                if count and count > 0 then
                    TriggerEvent('QBCore:Client:OnPlayerDeath')
                end
            end
        end
    end
end)

-- Evento per uso manuale dall'inventario
exports('orologiostellare:use', function(data, slot)
    TriggerEvent('QBCore:Client:OnPlayerDeath')
end)

Citizen.CreateThread(function()
    -- Attendi un po' che il gioco si stabilizzi
    Wait(3000)
    
    -- Avvia il monitoraggio (non dipende da QBCore)
    startDeathMonitoring()
end)