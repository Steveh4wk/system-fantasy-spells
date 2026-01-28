-- Stefano Luciano Corp
-- Handler centrale trasformazioni autorizzate dal server

RegisterNetEvent('fantasy_peds:client:becomeVampire', function()
    local playerId = PlayerId()
    local model = 'Vampire'
    local hash = joaat(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    SetPlayerModel(playerId, hash)
    SetModelAsNoLongerNeeded(hash)

    -- Notifica server che sei vampiro
    TriggerServerEvent('fantasy_creatures:server:setState', 'vampire')
    
    -- Aggiorna stato locale
    if CreatureSystem and CreatureSystem.SetCreatureState then
        CreatureSystem.SetCreatureState('isVampire', true)
    end
    
    if lib and lib.notify then
        lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Vampiro! 🧛'})
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 255},
            multiline = true,
            args = {"Fantasy Peds", "Sei diventato un Vampiro! 🧛"}
        })
    end
end)

RegisterNetEvent('fantasy_peds:client:becomeDemogorgon', function()
    local playerId = PlayerId()
    local model = 'u_m_y_zombie_01' -- MODELLO VALIDO PER TEST
    local hash = joaat(model)

    -- Controllo di sicurezza del modello
    if not IsModelValid(hash) then
        if lib and lib.notify then
            lib.notify({title = 'Errore', description = 'Modello Demogorgon non valido!', type = 'error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Errore", "Modello Demogorgon non valido!"}
            })
        end
        return
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000 -- 10 secondi timeout
    
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            if lib and lib.notify then
                lib.notify({title = 'Errore', description = 'Timeout caricamento modello Demogorgon!', type = 'error'})
            else
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Errore", "Timeout caricamento modello Demogorgon!"}
                })
            end
            return
        end
    end

    -- Controllo aggiuntivo prima del cambio modello
    if not IsModelInCdimage(hash) then
        if lib and lib.notify then
            lib.notify({title = 'Errore', description = 'Modello Demogorgon non trovato!', type = 'error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Errore", "Modello Demogorgon non trovato!"}
            })
        end
        SetModelAsNoLongerNeeded(hash)
        return
    end

    SetPlayerModel(playerId, hash)
    SetModelAsNoLongerNeeded(hash)

    -- Notifica server che sei Demogorgon
    TriggerServerEvent('fantasy_creatures:server:setState', 'demogorgon')
    
    -- Aggiorna stato locale usando il sistema centralizzato
    exports['fantasy_peds']:SetCreatureState('isDemogorgon', true)
    
    if lib and lib.notify then
        lib.notify({title = 'Fantasy Peds', description = 'Sei diventato un Demogorgon! 👹'})
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 0},
            multiline = true,
            args = {"Fantasy Peds", "Sei diventato un Demogorgon! 👹"}
        })
    end
end)
