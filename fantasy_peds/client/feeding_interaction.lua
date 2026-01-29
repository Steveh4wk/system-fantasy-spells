-- ==========================================================
-- Fantasy Peds - Feeding Interaction System
-- Autore: Stefano Luciano Corp
-- Pulsante proximity per feeding quando trasformato
-- ==========================================================

local FEED_DISTANCE = 3.0
local ANIMAL_CHECK_INTERVAL = 500
local isTransformed = false
local nearbyAnimal = nil
local interactionShown = false

-- Funzione per controllare se il giocatore è trasformato
local function IsPlayerTransformed()
    local ped = PlayerPedId()
    return Entity(ped).state.isVampire == true or Entity(ped).state.isLycan == true
end

-- Funzione per trovare animali vicini
local function FindNearbyAnimal()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestAnimal = nil
    local closestDistance = FEED_DISTANCE
    
    -- Controlla tutti i ped nel gioco
    for _, ped in pairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedHuman(ped) == false then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestAnimal = ped
            end
        end
    end
    
    return closestAnimal, closestDistance
end

-- Funzione per mostrare/nascondere interazione
local function UpdateInteraction()
    isTransformed = IsPlayerTransformed()
    
    if not isTransformed then
        -- Nascondi interazione se non trasformato
        if interactionShown then
            interactionShown = false
            nearbyAnimal = nil
            -- Nascondi testo 3D se presente
            lib.hideTextUI()
        end
        return
    end
    
    -- Cerca animali vicini
    local animal, distance = FindNearbyAnimal()
    
    if animal and distance <= FEED_DISTANCE then
        nearbyAnimal = animal
        
        if not interactionShown then
            interactionShown = true
            
            -- Mostra testo 3D o pulsante
            local pedState = Entity(PlayerPedId()).state
            local feedType = pedState.isVampire and "🩸 Sfama [E]" or "🍖 Nutrimento [E]"
            
            lib.showTextUI(feedType, {
                position = "top-center",
                icon = "skull",
                style = {
                    borderRadius = 8,
                    backgroundColor = "#1a1a1a",
                    color = "#ffffff"
                }
            })
        end
    else
        -- Nascondi se nessun animale vicino
        if interactionShown then
            interactionShown = false
            nearbyAnimal = nil
            lib.hideTextUI()
        end
    end
end

-- Thread principale per controllo prossimità
CreateThread(function()
    while true do
        UpdateInteraction()
        Wait(ANIMAL_CHECK_INTERVAL)
    end
end)

-- Gestione input tastiera
CreateThread(function()
    while true do
        Wait(0)
        
        if interactionShown and nearbyAnimal and IsControlJustReleased(0, 38) then -- Tasto E
            -- Esegui feeding basato sul tipo di creatura
            local pedState = Entity(PlayerPedId()).state
            
            if pedState.isVampire then
                -- Feeding Vampiro
                exports['fantasy_peds']:FeedVampire(nearbyAnimal)
                lib.notify({title = 'Vampiro', description = 'Ti sei nutrito!', type = 'success'})
                
            elseif pedState.isLycan then
                -- Feeding Lycan - scegli tipo casualmente o mostra menu
                exports['fantasy_peds']:FeedLycan(nearbyAnimal, "meat")
                lib.notify({title = 'Lycan', description = 'Ti sei nutrito di carne!', type = 'success'})
            end
            
            -- Nascondi interazione dopo il feed
            interactionShown = false
            nearbyAnimal = nil
            lib.hideTextUI()
        end
    end
end)

-- Reset quando il giocatore cambia forma
RegisterNetEvent('playerSpawned', function()
    interactionShown = false
    nearbyAnimal = nil
    lib.hideTextUI()
end)

print('[INFO] Feeding Interaction System caricato! Usa [E] vicino agli animali quando trasformato')
