-- Stefano Luciano Corp
-- Sistema Server per Creature - Cooldown condiviso e sincronizzazione

local CreatureCooldowns = {}
local ActiveCreatures = {}
local COOLDOWN_TIME = 300 -- 5 minuti

-- ==============================
-- GESTIONE COOLDOWN CONDIVISO
-- ==============================
RegisterNetEvent('fantasy_creatures:server:requestTransform', function(creature)
    local src = source
    local now = os.time()

    if CreatureCooldowns[src] and CreatureCooldowns[src] > now then
        local timeLeft = CreatureCooldowns[src] - now
        TriggerClientEvent('fantasy_creatures:client:transformDenied', src, timeLeft)
        return
    end

    -- Imposta cooldown
    CreatureCooldowns[src] = now + COOLDOWN_TIME
    
    -- Approva trasformazione
    TriggerClientEvent('fantasy_creatures:client:transformApproved', src, creature)
end)

-- ==============================
-- SINCRONIZZAZIONE STATO CREATURE
-- ==============================
RegisterNetEvent('fantasy_creatures:server:setState', function(creature)
    local src = source
    ActiveCreatures[src] = creature
    
    -- Logging per debug
    print(string.format('[Fantasy Creatures] Player %s è diventato %s', GetPlayerName(src), creature))
end)

RegisterNetEvent('fantasy_creatures:server:clearState', function()
    local src = source
    local creature = ActiveCreatures[src]
    
    if creature then
        print(string.format('[Fantasy Creatures] Player %s ha smesso di essere %s', GetPlayerName(src), creature))
    end
    
    ActiveCreatures[src] = nil
end)

-- ==============================
-- ESPORTAZIONI PER ALTRI SCRIPT
-- ==============================
exports('GetPlayerCreature', function(src)
    return ActiveCreatures[src]
end)

exports('IsPlayerCreature', function(src, creature)
    return ActiveCreatures[src] == creature
end)

exports('GetAllActiveCreatures', function()
    return ActiveCreatures
end)

-- ==============================
-- PREVENZIONE LOGOUT DA CREATURE
-- ==============================
AddEventHandler('qb-multicharacter:server:logout', function()
    local src = source
    
    if ActiveCreatures[src] then
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            TriggerClientEvent('QBCore:Notify', src, 'Non puoi uscire mentre sei una creatura! Torna umano prima.', 'error')
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Fantasy Peds", "Non puoi uscire mentre sei una creatura! Torna umano prima."}
            })
        end
        return false -- Blocca logout
    end
    
    return true -- Permetti logout normale
end)

-- ==============================
-- CLEANUP PLAYER DISCONNECT
-- ==============================
AddEventHandler('playerDropped', function()
    local src = source
    CreatureCooldowns[src] = nil
    ActiveCreatures[src] = nil
end)

-- ==============================
-- COMANDI ADMIN PER DEBUG
-- ==============================
RegisterCommand('creature_list', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        print("=== Creature Attive ===")
        for src, creature in pairs(ActiveCreatures) do
            print(string.format("Player %s (%s): %s", GetPlayerName(src), src, creature))
        end
        print("======================")
    end
end, false)

RegisterCommand('creature_reset', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        if target then
            ActiveCreatures[target] = nil
            CreatureCooldowns[target] = nil
            print(string.format("Reset creature stato per player %s", target))
        end
    end
end, false)
