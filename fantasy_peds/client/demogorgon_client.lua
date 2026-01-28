-- Stefano Luciano Corp
-- Script client Demogorgon + Menu Abilità + Cooldown
-- Sistema autonomo separato dal Vampiro

local isDemogorgon = false                   -- Stato attuale del giocatore
local demogorgonCooldowns = {}               -- Tieni traccia dei cooldown delle abilità

-- ==============================
-- LISTA ABILITÀ DEMOGORGON
-- ==============================
local demogorgonAbilities = {
    mind_flay = {
        label = "Lamento Mentale",
        cooldown = 45,
        description = "Confonde le menti dei nemici vicini",
        action = function()
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Trova ped vicini
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance <= 10.0 and ped ~= playerPed then
                    -- Applica effetto di confusione
                    SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 0.25)
                    PlayPain(ped, 7, 0)
                end
            end
            
            lib.notify({title = 'Demogorgon', description = 'Lamento Mentale attivato!', type='success'})
        end
    },
    
    shadow_walk = {
        label = "Passo d'Ombra",
        cooldown = 60,
        description = "Diventi parzialmente invisibile per 15 secondi",
        action = function()
            local playerPed = PlayerPedId()
            SetEntityAlpha(playerPed, 100, false) -- Rendi semi-trasparente
            
            lib.notify({title = 'Demogorgon', description = 'Passo d\'Ombra attivato!', type='success'})
            
            -- Ripristina visibilità dopo 15 secondi
            SetTimeout(15000, function()
                SetEntityAlpha(playerPed, 255, false)
                lib.notify({title = 'Demogorgon', description = 'Passo d\'Ombra terminato', type='info'})
            end)
        end
    },
    
    void_scream = {
        label = "Urlo del Vuoto",
        cooldown = 90,
        description = "Urlo potente che spinge via i nemici",
        action = function()
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Effetto sonoro e visivo
            PlayPedAmbientSpeech(playerPed, "GENERIC_CURSE_HIGH", 1, 0)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.5)
            
            -- Spingi via i ped vicini
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance <= 15.0 and ped ~= playerPed then
                    local direction = pedCoords - playerCoords
                    local force = (15.0 - distance) / 15.0 * 10.0
                    ApplyForceToEntity(ped, 0, direction.x * force, direction.y * force, direction.z * force, 0, 0, 0, false, true, true, false)
                end
            end
            
            lib.notify({title = 'Demogorgon', description = 'Urlo del Vuoto attivato!', type='success'})
        end
    },
    
    regeneration = {
        label = "Rigenerazione Oscura",
        cooldown = 120,
        description = "Rigenera salute usando il potere dell'Upside Down",
        action = function()
            local playerPed = PlayerPedId()
            local health = GetEntityHealth(playerPed)
            local newHealth = math.min(health + 75, 200)
            SetEntityHealth(playerPed, newHealth)
            
            -- Effetto visivo scuro
            StartScreenEffect("DeathFailOut", 3000, false)
            
            lib.notify({title = 'Demogorgon', description = 'Rigenerato di ' .. (newHealth - health) .. ' HP!', type='success'})
        end
    },
    
    tentacle_attack = {
        label = "Attacco Tentacolo",
        cooldown = 30,
        description = "Attacco rapido con tentacolo oscuro",
        action = function()
            local playerPed = PlayerPedId()
            
            -- Animazione attacco
            TaskPlayAnim(playerPed, "melee@unarmed@streamed_core", "attack_0", 8.0, -8.0, -1, 48, 0, false, false, false)
            
            -- Danno area
            local playerCoords = GetEntityCoords(playerPed)
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)
                
                if distance <= 3.0 and ped ~= playerPed then
                    SetEntityHealth(ped, GetEntityHealth(ped) - 25)
                end
            end
            
            lib.notify({title = 'Demogorgon', description = 'Attacco Tentacolo eseguito!', type='success'})
        end
    }
}

-- ==============================
-- FUNZIONI COOLDOWN
-- ==============================
local function IsOnCooldown(abilityId)
    return demogorgonCooldowns[abilityId] and demogorgonCooldowns[abilityId] > GetGameTimer()
end

local function StartCooldown(abilityId, timeSec)
    demogorgonCooldowns[abilityId] = GetGameTimer() + (timeSec * 1000)
end

-- ==============================
-- TRASFORMAZIONE DEMOGORGON (LOGICA ESATTA COME VAMPIRO)
-- ==============================
RegisterCommand('become_demogorgon', function()
    exports['fantasy_peds']:RequestTransformation('demogorgon')
end)

-- ==============================
-- TORNA UMANO (PATCH ILLENIUM-APPEARANCE)
-- ==============================
local function RestoreHumanFromDB()
    -- Cleanup di TUTTO ciò che la creatura ha applicato
    local playerPed = PlayerPedId()
    
    -- Ripristina scala e trasparenza
    SetPedScale(playerPed, 1.0)
    SetEntityAlpha(playerPed, 255, false)
    
    -- Rimuovi effetti visivi
    StopScreenEffect("DeathFailOut")
    ResetPedMovementClipset(playerPed, 0.0)
    
    -- Reset stati creature
    isDemogorgon = false
    
    -- Notifica server che non sei più creatura
    exports['fantasy_peds']:ClearCreatureState()
    
    -- Prova illenium-appearance prima
    local success = pcall(function()
        TriggerServerEvent('illenium-appearance:server:loadAppearance')
    end)
    
    if success then
        if lib and lib.notify then
            lib.notify({
                title = 'Fantasy Peds',
                description = 'Sei tornato umano (skin caricata dal database)'
            })
        else
            TriggerEvent('chat:addMessage', {
                color = {0, 255, 0},
                multiline = true,
                args = {"Fantasy Peds", "Sei tornato umano (skin caricata dal database)"}
            })
        end
    else
        -- Fallback: forza ricarica del personaggio base
        local defaultModel = 'mp_m_freemode_01'
        local hash = joaat(defaultModel)

        RequestModel(hash)
        local timeout = GetGameTimer() + 5000
        
        while not HasModelLoaded(hash) do
            Wait(10)
            if GetGameTimer() > timeout then
                break
            end
        end

        if HasModelLoaded(hash) then
            SetPlayerModel(PlayerId(), hash)
            SetModelAsNoLongerNeeded(hash)
            
            -- Forza refresh completo
            local playerPed = PlayerPedId()
            SetEntityHealth(playerPed, GetEntityHealth(playerPed))
            SetPedArmour(playerPed, 0)
            
            if lib and lib.notify then
                lib.notify({
                    title = 'Fantasy Peds',
                    description = 'Sei tornato umano (fallback)'
                })
            else
                TriggerEvent('chat:addMessage', {
                    color = {0, 255, 0},
                    multiline = true,
                    args = {"Fantasy Peds", "Sei tornato umano (fallback)"}
                })
            end
        else
            if lib and lib.notify then
                lib.notify({
                    title = 'Errore',
                    description = 'Impossibile tornare umano!',
                    type = 'error'
                })
            else
                TriggerEvent('chat:addMessage', {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Errore", "Impossibile tornare umano!"}
                })
            end
        end
    end
end

RegisterCommand('revert_demogorgon', function()
    if isDemogorgon then
        RestoreHumanFromDB()
    else
        if lib and lib.notify then
            lib.notify({title='Demogorgon', description='Non sei un Demogorgon!', type='error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Demogorgon", "Non sei un Demogorgon!"}
            })
        end
    end
end)

-- ==============================
-- COMANDO EMERGENZA FORZA UMANO
-- ==============================
RegisterCommand('force_human', function()
    -- Forza reset completo indipendentemente dallo stato
    local playerPed = PlayerPedId()
    
    -- Reset tutti gli effetti
    SetPedScale(playerPed, 1.0)
    SetEntityAlpha(playerPed, 255, false)
    StopAllScreenEffects()
    ResetPedMovementClipset(playerPed, 0.0)
    
    -- Forza modello umano base
    local defaultModel = 'mp_m_freemode_01'
    local hash = joaat(defaultModel)

    RequestModel(hash)
    local timeout = GetGameTimer() + 3000
    
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            break
        end
    end

    if HasModelLoaded(hash) then
        SetPlayerModel(PlayerId(), hash)
        SetModelAsNoLongerNeeded(hash)
        
        -- Reset stati
        isDemogorgon = false
        exports['fantasy_peds']:ClearCreatureState()
        
        if lib and lib.notify then
            lib.notify({
                title = 'Emergenza',
                description = 'Forzato ritorno umano!'
            })
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 0},
                multiline = true,
                args = {"Emergenza", "Forzato ritorno umano!"}
            })
        end
    end
end)

-- ==============================
-- MENU ABILITÀ DEMOGORGON
-- ==============================
RegisterCommand('demogorgon_abilities', function()
    if not isDemogorgon then
        if lib and lib.notify then
            lib.notify({title='Demogorgon', description='Non sei un Demogorgon!', type='error'})
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"Demogorgon", "Non sei un Demogorgon!"}
            })
        end
        return
    end

    local options = {}

    -- Opzione Torna Umano
    options[#options+1] = {
        title = '👤 Torna Umano',
        description = 'Ripristina il tuo personaggio originale',
        onSelect = function()
            RestoreHumanFromDB()
        end
    }

    for abilityId, ability in pairs(demogorgonAbilities) do
        options[#options+1] = {
            title = ability.label,
            description = ability.description,
            onSelect = function()
                if not IsOnCooldown(abilityId) then
                    ability.action()
                    StartCooldown(abilityId, ability.cooldown)
                else
                    if lib and lib.notify then
                        lib.notify({title='Demogorgon', description='Abilità in cooldown!', type='error'})
                    else
                        TriggerEvent('chat:addMessage', {
                            color = {255, 0, 0},
                            multiline = true,
                            args = {"Demogorgon", "Abilità in cooldown!"}
                        })
                    end
                end
            end
        }
    end

    if lib and lib.registerContext then
        lib.registerContext({
            id = 'demogorgon_ability_menu',
            title = '👹 Poteri Demogorgon',
            options = options
        })
        lib.showContext('demogorgon_ability_menu')
    else
        -- Fallback se ox_lib non disponibile
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 0},
            multiline = true,
            args = {"Demogorgon", "Menu abilità non disponibile"}
        })
    end
end)

-- ==============================
-- ESPORT STATO
-- ==============================
exports('IsDemogorgon', function()
    return isDemogorgon
end)

exports('GetDemogorgonAbilities', function()
    return demogorgonAbilities
end)
