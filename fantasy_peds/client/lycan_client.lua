-- Stefano Luciano Corp
-- Fantasy Peds - Lycan Client (Safe Load + Animations)

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

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())

    Wait(100)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 2.0)
    
    -- Imposta stato Entity per ox_target
    if modelName == "icewolf" then
        local ped = PlayerPedId()
        Entity(ped).state.isVampire = false
        Entity(ped).state.isLycan = true
        Entity(ped).state.hunger = 100
        Entity(ped).state.thirst = 100
        print("[DEBUG] Stato Lycan impostato per ox_target")
    end
end

-- Comandi Lycan
RegisterCommand("become_lycan", function()
    TransformPlayerTo("icewolf")
end)

RegisterCommand("become_ice_wolf", function()
    TransformPlayerTo("icewolf")
end)

-- Feeding Licantropo
local function FeedLycan(animalPed, type)
    if not DoesEntityExist(animalPed) then return end
    TaskPlayAnim(PlayerPedId(), 'amb@world_human_gardener_plant@male@enter', 'enter', 8.0, -8.0, 2000, 0, 0, false, false, false)
    Wait(1500)

    -- Kill animal
    ApplyDamageToPed(animalPed, 5000, false)
    CreateThread(function()
        while not IsPedDeadOrDying(animalPed, true) do Wait(50) end
        Wait(2000)
        DeleteEntity(animalPed)
    end)

    -- Fame / sete
    local ped = PlayerPedId()
    if type == "meat" then
        Entity(ped).state.hunger = math.min(100, (Entity(ped).state.hunger or 0) + 15)
    elseif type == "water" then
        Entity(ped).state.thirst = math.min(100, (Entity(ped).state.thirst or 0) + 25)
    end
end

exports('FeedLycan', FeedLycan)
