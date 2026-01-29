-- Stefano Luciano Corp
-- Fantasy Peds - Vampire Client (Safe Load + Animations)
-- Integrazione Animal Farm + Feeding Vampiro

local function LoadPedModel(modelName)
    local model = GetHashKey(modelName)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end
    if not HasModelLoaded(model) then
        print("Errore: modello " .. modelName .. " non caricato")
        return nil
    end
    return model
end

local function TransformPlayerTo(modelName)
    local model = LoadPedModel(modelName)
    if not model then return end

    -- Set ped
    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())

    -- Delay minimo per sicurezza prima di modificatori
    Wait(100)

    -- Modificatori melee
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.5)
    
    -- Imposta stato Entity per ox_target
    if modelName == "Vampire" then
        local ped = PlayerPedId()
        Entity(ped).state.isVampire = true
        Entity(ped).state.isLycan = false
        Entity(ped).state.hunger = 100
        Entity(ped).state.thirst = 100
        print("[DEBUG] Stato Vampiro impostato per ox_target")
    end
end

-- Menu / Comandi Vampiro
RegisterCommand("become_vampire", function()
    TransformPlayerTo("Vampire")
end)

-- Funzione Feeding Vampiro
local function FeedOnAnimal(animalPed)
    if not DoesEntityExist(animalPed) then return end

    -- Animazione player
    TaskPlayAnim(PlayerPedId(), 'mp_player_intdrink', 'loop_bottle', 8.0, -8.0, 2000, 0, 0, false, false, false)
    Wait(1500)

    -- Kill animal correttamente
    ApplyDamageToPed(animalPed, 5000, false)
    CreateThread(function()
        while not IsPedDeadOrDying(animalPed, true) do Wait(50) end
        Wait(2000)
        DeleteEntity(animalPed)
    end)

    -- Aumenta fame Vampiro
    local ped = PlayerPedId()
    Entity(ped).state.hunger = math.min(100, (Entity(ped).state.hunger or 0) + 25)
    Entity(ped).state.thirst = math.min(100, (Entity(ped).state.thirst or 0) + 25)
    
    lib.notify({ title = 'Feeding', description = 'Ti sei nutrito', type = 'success' })
end

exports('FeedVampire', FeedOnAnimal)
