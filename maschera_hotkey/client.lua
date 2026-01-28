local maskIdToEquip = 1
local maskTextureToEquip = 0

-- Particellare txAdmin noclip smoke effect
local particleDict = "core"
local particleName = "ent_dst_elec_fire_sp"
local particleScale = 1.75
local particleDuration = 1500
local loopAmount = 7
local loopDelay = 75

-- Funzione per creare il particellare (effetto txAdmin noclip)
function CreateMaskParticle()
    local playerPed = PlayerPedId()
    
    RequestNamedPtfxAsset(particleDict)
    while not HasNamedPtfxAssetLoaded(particleDict) do
        Citizen.Wait(5)
    end
    
    -- Avvia animazione all'inizio dell'effetto
    PlayMaskAnimation()
    
    local particleTbl = {}
    for i = 0, loopAmount do
        UseParticleFxAsset(particleDict)
        local partiResult = StartParticleFxLoopedOnEntity(
            particleName,
            playerPed,
            0.0, 0.0, 0.0,      -- offset
            0.0, 0.0, 0.0,      -- rot
            particleScale,
            false, false, false -- axis
        )
        particleTbl[#particleTbl + 1] = partiResult
        Citizen.Wait(loopDelay)
    end
    
    Citizen.Wait(particleDuration)
    for _, parti in ipairs(particleTbl) do
        StopParticleFxLooped(parti, true)
    end
    RemoveNamedPtfxAsset(particleDict)
end

-- Funzione per l'animazione
function PlayMaskAnimation()
    local playerPed = PlayerPedId()
    local animDict = "anim@mp_snowball"
    local animName = "pickup_snowball"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 500, 0, 0, false, false, false)
end

local hotkey = 170 -- F3

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if IsControlJustPressed(0, hotkey) then
            local playerPed = PlayerPedId()
            local currentDrawable = GetPedDrawableVariation(playerPed, 1)
            
            -- Effetto fumo con animazioni integrate
            CreateMaskParticle()
            
            if currentDrawable == 0 then
                -- Nessuna maschera -> METTI
                SetPedComponentVariation(playerPed, 1, maskIdToEquip, maskTextureToEquip, 0)
                TriggerEvent('chat:addMessage', {color = {0, 255, 0}, multiline = true, args = {"Maschera", "Maschera indossata"}})
            else
                -- C'è una maschera -> TOGLI
                SetPedComponentVariation(playerPed, 1, 0, 0, 0)
                TriggerEvent('chat:addMessage', {color = {255, 0, 0}, multiline = true, args = {"Maschera", "Maschera rimossa"}})
            end
            
            Citizen.Wait(500)
        end
    end
end)
