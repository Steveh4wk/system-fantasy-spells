-- Stefano Luciano Corp. Dev

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('openTransformations', function(data, cb)
    -- Apre il menu delle trasformazioni di fantasy_peds
    TriggerEvent('fantasy_peds:client:openCreatureMenu')
    cb('ok')
end)

RegisterNetEvent('orologio_stellare:use', function()
    SetNuiFocus(false, false) -- inizializza
    Wait(50)

    SetNuiFocus(true, false) -- focus reale
    SendNUIMessage({ action = 'show' })

    Wait(8000)

    SendNUIMessage({ action = 'hide' })
    SetNuiFocus(false, false)
end)