-- ==========================================================
-- Fantasy Peds Creatures Client
-- Autore: Stefano Luciano Corp
-- Gestione Vampiri e Lycans + Torna Umano
-- ==========================================================

local isVampire = false
local isLycan = false
local isTransforming = false -- Protezione menu

-- ============================
-- Trasformazione Vampiro
-- ============================
RegisterNetEvent('fantasy_peds:transformVampire', function()
    if isTransforming then
        lib.notify({title='Attesa', description='Trasformazione in corso...', type='warning'})
        return
    end
    
    isTransforming = true
    local model = GetHashKey("Vampire")
    RequestModel(model)
    
    -- RequestModel con timeout
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        print("Errore: modello Vampire non caricato")
        lib.notify({title='Errore', description='Modello non caricato!', type='error'})
        isTransforming = false
        return
    end

    -- Debug
    print("Ped is ready:", HasModelLoaded(GetHashKey("Vampire")))
    print("Ped alive:", not IsPedDeadOrDying(PlayerPedId(), true))

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100) -- Delay sicuro prima di qualsiasi nativo aggiuntivo
    
    -- Applica modificatori in modo sicuro
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.5)

    isVampire = true
    isLycan = false
    isTransforming = false

    lib.notify({title='Trasformazione', description='Sei diventato un Vampiro!', type='success'})
    
    -- Animazioni in thread separato
    CreateThread(function()
        Wait(500) -- Aspetta che il ped sia completamente caricato
        -- Qui puoi aggiungere animazioni specifiche per Vampiro
        print("Animazioni Vampiro pronte")
    end)
end)

-- ============================
-- Trasformazione Lycan
-- ============================
RegisterNetEvent('fantasy_peds:transformLycan', function()
    if isTransforming then
        lib.notify({title='Attesa', description='Trasformazione in corso...', type='warning'})
        return
    end
    
    isTransforming = true
    local model = GetHashKey("icewolf")
    RequestModel(model)
    
    -- RequestModel con timeout
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        print("Errore: modello Lycan non caricato")
        lib.notify({title='Errore', description='Modello non caricato!', type='error'})
        isTransforming = false
        return
    end

    -- Debug
    print("Ped is ready:", HasModelLoaded(GetHashKey("icewolf")))
    print("Ped alive:", not IsPedDeadOrDying(PlayerPedId(), true))

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100) -- Delay sicuro prima di qualsiasi nativo aggiuntivo
    
    -- Applica modificatori in modo sicuro
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.5)

    isLycan = true
    isVampire = false
    isTransforming = false

    lib.notify({title='Trasformazione', description='Sei diventato un Lycan!', type='success'})
    
    -- Animazioni in thread separato
    CreateThread(function()
        Wait(500) -- Aspetta che il ped sia completamente caricato
        -- Qui puoi aggiungere animazioni specifiche per Lycan
        print("Animazioni Lycan pronte")
    end)
end)

-- ============================
-- Torna Umano
-- ============================
RegisterNetEvent('fantasy_peds:restoreHuman', function()
    if isTransforming then
        lib.notify({title='Attesa', description='Trasformazione in corso...', type='warning'})
        return
    end
    
    isTransforming = true
    local model = GetHashKey("mp_m_freemode_01") -- umano standard
    RequestModel(model)
    
    -- RequestModel con timeout
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        print("Errore: modello umano non caricato")
        lib.notify({title='Errore', description='Modello non caricato!', type='error'})
        isTransforming = false
        return
    end

    -- Debug
    print("Ped is ready:", HasModelLoaded(GetHashKey("mp_m_freemode_01")))
    print("Ped alive:", not IsPedDeadOrDying(PlayerPedId(), true))

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100) -- Delay sicuro prima di qualsiasi nativo aggiuntivo
    
    -- Resetta modificatori in modo sicuro
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)

    isVampire = false
    isLycan = false
    isTransforming = false

    lib.notify({title='Trasformazione', description='Sei tornato umano', type='success'})
    
    -- Resetta animazioni in thread separato
    CreateThread(function()
        Wait(500) -- Aspetta che il ped sia completamente caricato
        print("Animazioni umane pronte")
    end)
end)

-- ============================
-- Stato Creature
-- ============================
function IsVampire()
    return isVampire
end

function IsLycan()
    return isLycan
end

-- ============================
-- Comandi Diretti
-- ============================
RegisterCommand('become_vampire', function()
    TriggerEvent('fantasy_peds:transformVampire')
end)

RegisterCommand('become_lycan', function()
    TriggerEvent('fantasy_peds:transformLycan')
end)

RegisterCommand('become_ice_wolf', function()
    TriggerEvent('fantasy_peds:transformLycan')
end)

RegisterCommand('restore_human', function()
    TriggerEvent('fantasy_peds:restoreHuman')
end)

-- ============================
-- Menu / Creatures
-- ============================
RegisterCommand('creatures', function()
    -- Debug: Check if lib is available
    print('[DEBUG] lib available:', lib ~= nil)
    print('[DEBUG] lib.registerContext available:', lib and lib.registerContext ~= nil)
    
    local options = {
        {
            title = "Vampiro [1]",
            description = "Trasformati in Vampiro - Premi 1",
            icon = "skull",
            onSelect = function()
                -- Usa il comando diretto dal vampire_client.lua
                ExecuteCommand("become_vampire")
            end
        },
        {
            title = "Lycan [2]",
            description = "Trasformati in Lycan - Premi 2",
            icon = "paw",
            onSelect = function()
                -- Usa il comando diretto dal lycan_client.lua
                ExecuteCommand("become_lycan")
            end
        },
        {
            title = "Ice Wolf [3]",
            description = "Trasformati in Ice Wolf - Premi 3",
            icon = "paw",
            onSelect = function()
                -- Usa il comando diretto dal lycan_client.lua
                ExecuteCommand("become_ice_wolf")
            end
        },
        {
            title = "Torna Umano [4]",
            description = "Ripristina forma umana - Premi 4",
            icon = "user",
            onSelect = function()
                -- Comando standard per tornare umano
                local model = GetHashKey("mp_m_freemode_01")
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(10) end
                
                SetPlayerModel(PlayerId(), model)
                SetPedDefaultComponentVariation(PlayerPedId())
                Wait(100)
                SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
                
                -- Resetta stato Entity per ox_target
                local ped = PlayerPedId()
                Entity(ped).state.isVampire = false
                Entity(ped).state.isLycan = false
                Entity(ped).state.hunger = 100
                Entity(ped).state.thirst = 100
                print("[DEBUG] Stato Umano impostato per ox_target")
                
                lib.notify({title='Trasformazione', description='Sei tornato umano', type='success'})
            end
        }
    }

    if lib and lib.registerContext then
        print('[DEBUG] Showing ox_lib menu')
        lib.registerContext({
            id = 'creature_menu',
            title = '🌙 Menu Creature',
            options = options
        })

        lib.showContext('creature_menu')
    else
        -- Fallback: Show chat menu if ox_lib not available
        print('[DEBUG] ox_lib not available, using chat menu')
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 100},
            multiline = true,
            args = {"🌙 Menu Creature", "Usa i comandi diretti:"}
        })
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "1. /become_vampire - Diventa Vampiro"}
        })
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "2. /become_lycan - Diventa Lycan"}
        })
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "3. /become_ice_wolf - Diventa Ice Wolf"}
        })
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "4. /restore_human - Torna umano"}
        })
    end
end)

-- ============================
-- Funzione Menu Esterna (per ox_target)
-- ============================
function OpenCreaturesMenu()
    local menu = {
        {
            label = "Vampiro",
            icon = "skull",
            onSelect = function()
                ExecuteCommand("become_vampire")
            end
        },
        {
            label = "Lycan",
            icon = "paw",
            onSelect = function()
                ExecuteCommand("become_lycan")
            end
        },
        {
            label = "Ice Wolf",
            icon = "paw",
            onSelect = function()
                ExecuteCommand("become_ice_wolf")
            end
        },
        {
            label = "Torna umano",
            icon = "user",
            onSelect = function()
                local model = GetHashKey("mp_m_freemode_01")
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(10) end
                
                SetPlayerModel(PlayerId(), model)
                SetPedDefaultComponentVariation(PlayerPedId())
                Wait(100)
                SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
                
                lib.notify({title='Trasformazione', description='Sei tornato umano', type='success'})
            end
        }
    }
    
    if lib and lib.showContextMenu then
        lib.showContextMenu(menu)
    end
end
