-- Stefano Luciano Corp
-- Sistema Server per Creature - Cooldown condiviso e sincronizzazione
-- VERSIONE COMPLETA - SISTEMA PERMESSI RAZZA

local CreatureCooldowns = {}
local ActiveCreatures = {}
local PlayerRaces = {} -- Salva le razze dei player
local COOLDOWN_TIME = 300 -- 5 minuti

-- ==============================
-- SISTEMA PERMESSI RAZZA
-- ==============================
RegisterNetEvent('fantasy_creatures:server:checkRacePermission', function(race)
    local src = source
    local playerId = GetPlayerIdentifier(src)
    
    -- Per ora permette a tutti (da configurare con whitelist/database)
    -- TODO: Integrare con database player per salvare razze permanenti
    
    if not PlayerRaces[playerId] then
        PlayerRaces[playerId] = {}
    end
    
    -- Check se il player ha questa razza sbloccata
    if not PlayerRaces[playerId][race] then
        -- Per ora auto-sblocca la prima volta (da cambiare con sistema progressione)
        PlayerRaces[playerId][race] = true
        
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            TriggerClientEvent('QBCore:Notify', src, 'Hai sbloccato la razza ' .. race .. '!', 'success')
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Sistema Razze", "Hai sbloccato la razza " .. race .. "!"}
            })
        end
    end
    
    -- Procedi con il check cooldown
    local now = os.time()

    if CreatureCooldowns[src] and CreatureCooldowns[src] > now then
        local timeLeft = CreatureCooldowns[src] - now
        TriggerClientEvent('fantasy_creatures:client:transformDenied', src, timeLeft)
        return
    end

    -- Imposta cooldown
    CreatureCooldowns[src] = now + COOLDOWN_TIME
    
    -- Approva trasformazione
    TriggerClientEvent('fantasy_creatures:client:transformApproved', src, race)
end)

-- ==============================
-- GESTIONE COOLDOWN CONDIVISO (LEGACY)
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
-- SISTEMA TRACKING FEEDING ANIMALI
-- ==============================
local AnimalFeedStats = {} -- Statistiche feeding per player

RegisterNetEvent('fantasy_creatures:server:animalFed', function(animalModel)
    local src = source
    local playerId = GetPlayerIdentifier(src)
    
    if not AnimalFeedStats[playerId] then
        AnimalFeedStats[playerId] = {
            totalFeeds = 0,
            lastFeedTime = 0,
            animalsFed = {}
        }
    end
    
    AnimalFeedStats[playerId].totalFeeds = AnimalFeedStats[playerId].totalFeeds + 1
    AnimalFeedStats[playerId].lastFeedTime = os.time()
    
    -- Aggiungi alla lista animali nutriti
    local modelName = tostring(animalModel)
    AnimalFeedStats[playerId].animalsFed[modelName] = (AnimalFeedStats[playerId].animalsFed[modelName] or 0) + 1
    
    print(string.format('[Fantasy Creatures] Player %s ha nutrito di un animale: %s (totale: %d)', 
        GetPlayerName(src), modelName, AnimalFeedStats[playerId].totalFeeds))
end)

-- Export per ottenere statistiche feeding
exports('GetPlayerFeedStats', function(src)
    local playerId = GetPlayerIdentifier(src)
    return AnimalFeedStats[playerId] or { totalFeeds = 0, lastFeedTime = 0, animalsFed = {} }
end)

-- Export per uso item (compatibilità ox_inventory)
exports('useItem', function(source, itemName)
    if itemName == 'sangue' then
        -- Trigger client event per uso sangue
        TriggerClientEvent('player:useItem', source, 'sangue')
    elseif itemName == 'raw_meat' then
        -- Trigger client event per uso carne cruda
        TriggerClientEvent('player:useItem', source, 'raw_meat')
    elseif itemName == 'water_bottle' then
        -- Trigger client event per uso acqua
        TriggerClientEvent('player:useItem', source, 'water_bottle')
    end
end)

-- ==============================
-- CLEANUP PLAYER DISCONNECT
-- ==============================
AddEventHandler('playerDropped', function()
    local src = source
    CreatureCooldowns[src] = nil
    ActiveCreatures[src] = nil
    
    -- Pulisci statistiche feeding
    local playerId = GetPlayerIdentifier(src)
    AnimalFeedStats[playerId] = nil
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

RegisterCommand('feeding_stats', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        print("=== Statistiche Feeding Animali ===")
        for playerId, stats in pairs(AnimalFeedStats) do
            print(string.format("Player ID: %s", playerId))
            print(string.format("  Total Feeds: %d", stats.totalFeeds))
            print(string.format("  Last Feed: %s", os.date("%H:%M:%S", stats.lastFeedTime)))
            print("  Animals Fed:")
            for animal, count in pairs(stats.animalsFed) do
                print(string.format("    %s: %d", animal, count))
            end
            print("----------------------")
        end
        print("================================")
    end
end, false)

-- ==============================
-- COMANDI ADMIN COMPLETI
-- ==============================
RegisterCommand('creature_debug', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        if target then
            print(string.format("=== DEBUG CREATURE PLAYER %s ===", GetPlayerName(target)))
            print(string.format("Stato Creature: %s", ActiveCreatures[target] or "Nessuna"))
            print(string.format("Cooldown: %s", CreatureCooldowns[target] and os.date("%H:%M:%S", CreatureCooldowns[target]) or "Nessuno"))
            
            local stats = AnimalFeedStats[GetPlayerIdentifier(target)]
            if stats then
                print(string.format("Feeding Stats: %d total, last: %s", stats.totalFeeds, os.date("%H:%M:%S", stats.lastFeedTime)))
            end
            print("=============================")
        else
            print("Uso: /creature_debug [player_id]")
        end
    end
end, false)

RegisterCommand('hunger_set', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        local value = tonumber(args[2])
        if target and value then
            TriggerClientEvent('fantasy_creatures:client:setHunger', target, value)
            print(string.format("Settato hunger a %d per player %s", value, GetPlayerName(target)))
        else
            print("Uso: /hunger_set [player_id] [value]")
        end
    end
end, false)

RegisterCommand('thirst_set', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        local value = tonumber(args[2])
        if target and value then
            TriggerClientEvent('fantasy_creatures:client:setThirst', target, value)
            print(string.format("Settato thirst a %d per player %s", value, GetPlayerName(target)))
        else
            print("Uso: /thirst_set [player_id] [value]")
        end
    end
end, false)

RegisterCommand('creature_force', function(source, args, rawCommand)
    if source == 0 or (QBCore and QBCore.Functions and QBCore.Functions.HasPermission and QBCore.Functions.HasPermission(source, 'admin')) then
        local target = tonumber(args[1])
        local creature = args[2]
        if target and creature then
            TriggerClientEvent('fantasy_creatures:client:transformApproved', target, creature)
            print(string.format("Forzata trasformazione in %s per player %s", creature, GetPlayerName(target)))
        else
            print("Uso: /creature_force [player_id] [vampire|lycan]")
        end
    end
end, false)
