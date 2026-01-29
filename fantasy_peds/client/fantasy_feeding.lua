--- ==========================================================
-- FANTASY FEEDING SYSTEM: VAMPIRO & LYCAN
-- Autore: Stefano Luciano Corp
-- ==========================================================

local FEED_DISTANCE = 50.0
local WATER_DISTANCE = 3.0

-- globals
function IsVampire()
    return Entity(PlayerPedId()).state.isVampire == true
end

function IsLycan()
    return Entity(PlayerPedId()).state.isLycan == true
end

function SetPlayerState(vamp, lyc)
    local ped = PlayerPedId()
    Entity(ped).state.isVampire = vamp or false
    Entity(ped).state.isLycan = lyc or false
    Entity(ped).state.hunger = 100
    Entity(ped).state.thirst = 100
end

function AddHunger(amount)
    local ped = PlayerPedId()
    Entity(ped).state.hunger = math.min(100, (Entity(ped).state.hunger or 0) + amount)
end

function AddThirst(amount)
    local ped = PlayerPedId()
    Entity(ped).state.thirst = math.min(100, (Entity(ped).state.thirst or 0) + amount)
end

-- kill animale
function KillAnimalProperly(animalPed)
    if not DoesEntityExist(animalPed) then return end
    SetEntityInvincible(animalPed, false)
    FreezeEntityPosition(animalPed, false)
    ClearPedTasks(animalPed)
    ApplyDamageToPed(animalPed, 5000, false)

    CreateThread(function()
        local timeout = GetGameTimer() + 6000
        while DoesEntityExist(animalPed) and not IsPedDeadOrDying(animalPed, true) and GetGameTimer() < timeout do
            Wait(50)
        end
        Wait(2000)
        if DoesEntityExist(animalPed) then
            DeleteEntity(animalPed)
        end
    end)
end

-- usa item
RegisterNetEvent('player:useItem', function(itemName)
    local ped = PlayerPedId()
    if IsVampire() then
        if itemName == 'blood_bottle' then
            TaskPlayAnim(ped, 'mp_player_intdrink', 'loop_bottle', 8.0, -8.0, 2000, 0, 0, false, false, false)
            Wait(2000)
            AddHunger(40)
            AddThirst(40)
            lib.notify({title='Sangue', description='Hai bevuto sangue!', type='success'})
            TriggerEvent('player:removeItem', itemName, 1)
            return
        end
        lib.notify({title='Vampiro', description='Cibo normale non sfama', type='error'})
        return
    end
    if IsLycan() then
        if itemName == 'raw_meat' then
            TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@enter', 'enter', 8.0, -8.0, 2000, 0, 0, false, false, false)
            Wait(2000)
            AddHunger(25)
            lib.notify({title='Lycan', description='Hai mangiato carne', type='success'})
            TriggerEvent('player:removeItem', itemName, 1)
            return
        elseif itemName == 'water_bottle' then
            TaskPlayAnim(ped, 'mp_player_intdrink', 'loop_bottle', 8.0, -8.0, 2000, 0, 0, false, false, false)
            Wait(2000)
            AddThirst(25)
            lib.notify({title='Lycan', description='Hai bevuto acqua', type='success'})
            TriggerEvent('player:removeItem', itemName, 1)
            return
        end
    end
    TriggerEvent('player:consumeItem', itemName)
end)

-- feed animale
RegisterNetEvent('fantasy_animals:feed', function(animalPed)
    if not DoesEntityExist(animalPed) then return end
    local ped = PlayerPedId()
    if IsVampire() then
        TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@enter','enter',8.0,-8.0,2000,0,0,false,false,false)
        Wait(1500)
        KillAnimalProperly(animalPed)
        AddHunger(25)
        AddThirst(25)
        lib.notify({title='Vampiro', description='Hai mangiato animale', type='success'})
    elseif IsLycan() then
        TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@enter','enter',8.0,-8.0,2000,0,0,false,false,false)
        Wait(1500)
        KillAnimalProperly(animalPed)
        AddHunger(25)
        lib.notify({title='Lycan', description='Hai mangiato animale', type='success'})
    end
end)

-- target animali
CreateThread(function()
    while true do
        Wait(1000)
        if not (IsVampire() or IsLycan()) then goto continue end
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for _, animalPed in pairs(GetGamePool('CPed')) do
            if DoesEntityExist(animalPed) and (IsPedAnimal(animalPed) or IsPedHuman(animalPed) == false) then
                local dist = #(coords - GetEntityCoords(animalPed))
                if dist <= FEED_DISTANCE and not Entity(animalPed).state.feedable then
                    Entity(animalPed).state.feedable = true
                    exports.ox_target:addLocalEntity(animalPed,{
                        {label='🩸 Sfama',icon='skull',distance=2.0,onSelect=function()
                            TriggerEvent('fantasy_animals:feed', animalPed)
                        end}
                    })
                    CreateThread(function()
                        Wait(15000)
                        if DoesEntityExist(animalPed) then Entity(animalPed).state.feedable = false end
                    end)
                end
            end
        end
        ::continue::
    end
end)

-- bere acqua naturale lycan
CreateThread(function()
    while true do
        Wait(1000)
        if not IsLycan() then goto continue end
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local waterHeight = GetWaterHeight(coords.x, coords.y, coords.z)
        if waterHeight then
            exports.ox_target:addSphere(coords,WATER_DISTANCE,{
                {label='Bere acqua 💧',icon='tint',onSelect=function()
                    TaskPlayAnim(ped,'mp_player_intdrink','loop_bottle',8.0,-8.0,2000,0,0,false,false,false)
                    Wait(2000)
                    AddThirst(25)
                    lib.notify({title='Lycan',description='Hai bevuto acqua',type='success'})
                end}
            })
        end
        ::continue::
    end
end)
