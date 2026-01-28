local QBCore = exports['qb-core']:GetCoreObject()

-- Callback per riempire la fiala
QBCore.Functions.CreateCallback('fiala_ricordi:server:fillVial', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    -- Controlla se ha una fiala vuota
    local hasEmpty = exports.ox_inventory:Search(source, 'count', Config.ItemName)
    
    if hasEmpty and hasEmpty > 0 then
        -- Rimuovi la fiala vuota
        exports.ox_inventory:RemoveItem(source, Config.ItemName, 1)
        
        -- Aggiungi la fiala piena
        exports.ox_inventory:AddItem(source, Config.FilledItemName, 1)
        
        TriggerClientEvent('fiala_ricordi:client:vialFilled', source)
        cb(true)
    else
        TriggerClientEvent('fiala_ricordi:client:noEmptyVial', source)
        cb(false)
    end
end)

-- Evento per usare la fiala piena
RegisterNetEvent('fiala_ricordi:server:useVial', function()
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    -- Controlla se ha una fiala piena
    local hasFilled = exports.ox_inventory:Search(source, 'count', Config.FilledItemName)
    
    if hasFilled and hasFilled > 0 then
        -- Rimuovi la fiala piena
        exports.ox_inventory:RemoveItem(source, Config.FilledItemName, 1)
        
        -- Effetti della fiala (es. salute piena, armatura, etc.)
        local ped = GetPlayerPed(source)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        
        TriggerClientEvent('fiala_ricordi:client:vialUsed', source)
    end
end)
