-- Stefano Luciano Corp. Dev - Fantasy Status System with Creature Integration

local isStatusVisible = false
local playerData = {
    name = "",
    creature = "human",
    status = {
        health = 100,
        armor = 0,
        hunger = 100,
        thirst = 100,
        stress = 0,
        creaturePower = 0
    }
}

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('ready', function(data, cb)
    -- NUI is ready, send initial data
    UpdatePlayerData()
    cb('ok')
end)

-- Update player data and send to NUI
function UpdatePlayerData()
    local playerPed = PlayerPedId()
    
    -- Update basic status
    playerData.status.health = GetEntityHealth(playerPed)
    playerData.status.armor = GetPedArmour(playerPed)
    
    -- Get player name
    playerData.name = GetPlayerName(PlayerId())
    
    -- Check creature status
    if exports['fantasy_peds']:IsVampire() then
        playerData.creature = "vampire"
        -- Get vampire-specific data
        local vampireState = exports['fantasy_peds']:GetVampireState()
        playerData.status.creaturePower = vampireState.bloodVisionActive and 100 or 0
    elseif exports['fantasy_peds']:IsLycan() then
        playerData.creature = "lycan"
        -- Get lycan-specific data
        local lycanState = exports['fantasy_peds']:GetLycanState()
        playerData.status.creaturePower = lycanState.rageLevel or 0
    else
        playerData.creature = "human"
        playerData.status.creaturePower = 0
    end
    
    -- Get hunger/thirst from fantasy_feeding system if creature, otherwise default
    if playerData.creature ~= "human" then
        playerData.status.hunger = exports['fantasy_peds']:GetHunger() or 100
        playerData.status.thirst = exports['fantasy_peds']:GetThirst() or 100
    else
        -- Default human hunger/thirst (could be integrated with other systems)
        playerData.status.hunger = playerData.status.hunger or 100
        playerData.status.thirst = playerData.status.thirst or 100
    end
    
    -- Get stress (could be integrated with other systems)
    playerData.status.stress = playerData.status.stress or 0
    
    -- Send data to NUI if visible
    if isStatusVisible then
        SendNUIMessage({
            action = 'updateStatus',
            status = playerData.status
        })
        
        SendNUIMessage({
            action = 'updateCreature',
            creature = playerData.creature
        })
        
        SendNUIMessage({
            action = 'updatePlayerName',
            name = playerData.name
        })
    end
end

-- Toggle status visibility
function ToggleStatus()
    isStatusVisible = not isStatusVisible
    
    if isStatusVisible then
        SetNuiFocus(true, false)
        SendNUIMessage({ action = 'show' })
        UpdatePlayerData()
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hide' })
    end
end

-- Status update loop
CreateThread(function()
    while true do
        Wait(1000) -- Update every second
        
        if isStatusVisible then
            UpdatePlayerData()
        end
    end
end)

-- Event handlers
RegisterNetEvent('orologio_stellare:use', function()
    ToggleStatus()
end)

RegisterNetEvent('fantasy_creatures:client:transformApproved', function(creature)
    -- Update creature status when transformed
    Wait(1000) -- Wait for transformation to complete
    UpdatePlayerData()
end)

RegisterNetEvent('fantasy_creatures:client:restoreHuman', function()
    -- Update when restored to human
    Wait(1000) -- Wait for restoration to complete
    UpdatePlayerData()
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(hunger, thirst)
    -- Update hunger/thirst when fantasy_peds sends updates
    if playerData.creature ~= "human" then
        playerData.status.hunger = hunger
        playerData.status.thirst = thirst
        
        if isStatusVisible then
            SendNUIMessage({
                action = 'updateStatus',
                status = playerData.status
            })
        end
    end
end)

-- Hotkey per aprire status (tasto H)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 74) then -- Tasto H
            ToggleStatus()
        end
    end
end)

-- Hotkey per menu creatures (tasto C)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 26) then -- Tasto C
            TriggerEvent('creatures')
        end
    end
end)

-- Auto-hide after 10 seconds
CreateThread(function()
    while true do
        Wait(1000)
        
        if isStatusVisible then
            -- You could add auto-hide logic here if needed
            -- For now, status stays visible until manually closed
        end
    end
end)

-- Export for other scripts to update status
exports('UpdateStatus', function(statusData)
    if statusData then
        for key, value in pairs(statusData) do
            if playerData.status[key] ~= nil then
                playerData.status[key] = value
            end
        end
        UpdatePlayerData()
    end
end)

exports('IsStatusVisible', function()
    return isStatusVisible
end)

print('[INFO] Fantasy Status System loaded with Creature Integration')