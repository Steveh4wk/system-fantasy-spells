local QBCore = exports['qb-core']:GetCoreObject()

-- Evento per dare arma al player quando spawn
AddEventHandler('playerSpawned', function()
    Citizen.Wait(1000) -- Attendi 1 secondo per assicurarsi che il player sia completamente caricato
    
    local playerPed = PlayerPedId()
    
    -- Dà una pistola di default
    GiveWeaponToPed(playerPed, `WEAPON_PISTOL`, 100, false, true)
    
    -- Notifica il player
    QBCore.Functions.Notify('Arma di default data per test', 'info', 3000)
end)

-- Comando per dare arma manualmente (per test)
RegisterCommand('darma', function()
    local playerPed = PlayerPedId()
    GiveWeaponToPed(playerPed, `WEAPON_PISTOL`, 100, false, true)
    QBCore.Functions.Notify('Pistola data', 'success', 2000)
end, false)
