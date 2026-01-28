local QBCore = exports['qb-core']:GetCoreObject()
local isCooldown = false

-- Evento per usare la fiala vuota
exports('fiala_ricordi_vuota:use', function(data, slot)
    if isCooldown then
        TriggerEvent('QBCore:Notify', Config.Messages.cooldown, 'error')
        return
    end
    
    TriggerServerEvent('fiala_ricordi:server:fillVial')
end)

-- Evento per usare la fiala piena
exports('fiala_ricordi_piena:use', function(data, slot)
    if isCooldown then
        TriggerEvent('QBCore:Notify', Config.Messages.cooldown, 'error')
        return
    end
    
    isCooldown = true
    TriggerServerEvent('fiala_ricordi:server:useVial')
    
    SetTimeout(Config.CooldownTime, function()
        isCooldown = false
    end)
end)

-- Eventi dal server
RegisterNetEvent('fiala_ricordi:client:vialFilled', function()
    TriggerEvent('QBCore:Notify', Config.Messages.filled, 'success')
end)

RegisterNetEvent('fiala_ricordi:client:vialUsed', function()
    TriggerEvent('QBCore:Notify', Config.Messages.used, 'info')
end)

RegisterNetEvent('fiala_ricordi:client:alreadyFilled', function()
    TriggerEvent('QBCore:Notify', Config.Messages.already_filled, 'error')
end)

RegisterNetEvent('fiala_ricordi:client:noEmptyVial', function()
    TriggerEvent('QBCore:Notify', Config.Messages.no_empty, 'error')
end)
