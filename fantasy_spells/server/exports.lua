-- Ottimizzazione cache + controlli server-side
local QBCore = exports['qb-core']:GetCoreObject()

-- Import functions from database
local function GetCitizenId(source)
    local player = QBCore.Functions.GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function UpdatePlayerData(citizenId, column, value)
    -- Update cache
    if PlayerDataCache and PlayerDataCache[citizenId] then
        PlayerDataCache[citizenId][column] = value
    end

    -- Update database
    if column == 'skills' then
        value = json.encode(value)
    end

    MySQL.update('UPDATE fantasy_players SET '..column..' = ? WHERE citizenid = ?', { value, citizenId })
end

local function GetPlayerData(source)
    local citizenId = GetCitizenId(source)
    if not citizenId then return end
    
    -- Try to get from cache first
    if PlayerDataCache and PlayerDataCache[citizenId] then
        return PlayerDataCache[citizenId]
    end
    
    -- Load from database if not in cache
    local data = MySQL.single.await(
        'SELECT * FROM fantasy_players WHERE citizenid = ?',
        { citizenId }
    )

    if not data then
        MySQL.insert.await(
            'INSERT INTO fantasy_players (citizenid, skills) VALUES (?, ?)',
            { citizenId, json.encode({}) }
        )
        data = { citizenid = citizenId, is_vampire = 0, is_werewolf = 0, animagus_animal = nil, skills = '{}' }
    end

    -- Decode skills
    data.skills = json.decode(data.skills or '{}')
    
    -- Cache the data
    if PlayerDataCache then
        PlayerDataCache[citizenId] = data
    end
    
    return data
end

print('[fantasy_spells] Loading exports...')

-- Test export
exports('TestExport', function()
    print('[fantasy_spells] TestExport called successfully!')
    return 'working'
end)

-- Vampire exports (moved to top)
exports('UnlockVampire', function(source)
    print('[fantasy_spells] UnlockVampire called for source:', source)
    local data = GetPlayerData(source)
    if data.is_vampire == 1 then 
        print('[fantasy_spells] Player is already vampire')
        return 
    end
    UpdatePlayerData(data.citizenid, 'is_vampire', 1)
    print('[fantasy_spells] Vampire status updated for:', data.citizenid)
end)

exports('HasVampire', function(source)
    print('[fantasy_spells] HasVampire called for source:', source)
    local data = GetPlayerData(source)
    local result = data and data.is_vampire == 1
    print('[fantasy_spells] HasVampire result:', result)
    return result
end)

-- Event-based system following TH pattern
RegisterServerEvent('fantasy_spells:server:CheckVampire')
AddEventHandler('fantasy_spells:server:CheckVampire', function()
    local source = source
    local data = GetPlayerData(source)
    local isVampire = data and data.is_vampire == 1
    TriggerClientEvent('fantasy_spells:client:VampireCheckResult', source, isVampire)
end)

RegisterServerEvent('fantasy_spells:server:CheckWerewolf')
AddEventHandler('fantasy_spells:server:CheckWerewolf', function()
    local source = source
    local data = GetPlayerData(source)
    local isWerewolf = data and data.is_werewolf == 1
    TriggerClientEvent('fantasy_spells:client:WerewolfCheckResult', source, isWerewolf)
end)

RegisterServerEvent('fantasy_spells:server:GetVampireSpells')
AddEventHandler('fantasy_spells:server:GetVampireSpells', function()
    local source = source
    TriggerClientEvent('fantasy_spells:client:VampireSpellsResult', source, Config.VampireSpells or {})
end)

RegisterServerEvent('fantasy_spells:server:GetAnimagusAnimal')
AddEventHandler('fantasy_spells:server:GetAnimagusAnimal', function()
    local source = source
    local data = GetPlayerData(source)
    TriggerClientEvent('fantasy_spells:client:AnimagusAnimalResult', source, data and data.animagus_animal)
end)

RegisterServerEvent('fantasy_spells:server:GetAnimagusSpells')
AddEventHandler('fantasy_spells:server:GetAnimagusSpells', function()
    local source = source
    TriggerClientEvent('fantasy_spells:client:AnimagusSpellsResult', source, Config.AnimagusSpells or {})
end)

RegisterServerEvent('fantasy_spells:server:GetLycanSpells')
AddEventHandler('fantasy_spells:server:GetLycanSpells', function()
    local source = source
    TriggerClientEvent('fantasy_spells:client:LycanSpellsResult', source, Config.LycanSpells or {})
end)

-- Unlock events as fallback for failed exports
RegisterServerEvent('fantasy_spells:server:UnlockVampire')
AddEventHandler('fantasy_spells:server:UnlockVampire', function()
    local source = source
    print('[fantasy_spells] UnlockVampire event called for source:', source)
    local data = GetPlayerData(source)
    if data.is_vampire == 1 then
        print('[fantasy_spells] Player is already vampire')
        return
    end
    UpdatePlayerData(data.citizenid, 'is_vampire', 1)
    print('[fantasy_spells] Vampire status updated for:', data.citizenid)
end)

RegisterServerEvent('fantasy_spells:server:UnlockWerewolf')
AddEventHandler('fantasy_spells:server:UnlockWerewolf', function()
    local source = source
    print('[fantasy_spells] UnlockWerewolf event called for source:', source)
    local data = GetPlayerData(source)
    if data.is_werewolf == 1 then
        print('[fantasy_spells] Player is already werewolf')
        return
    end
    UpdatePlayerData(data.citizenid, 'is_werewolf', 1)
    print('[fantasy_spells] Werewolf status updated for:', data.citizenid)
end)

-- Razze
exports('IsVampire', function(source)
    local data = GetPlayerData(source)
    return data and data.is_vampire == 1
end)

exports('HasVampire', function(source)
    local data = GetPlayerData(source)
    return data and data.is_vampire == 1
end)

exports('UnlockWerewolf', function(source)
    local data = GetPlayerData(source)
    if data.is_werewolf == 1 then return end
    UpdatePlayerData(data.citizenid, 'is_werewolf', 1)
end)

exports('IsWerewolf', function(source)
    local data = GetPlayerData(source)
    return data and data.is_werewolf == 1
end)

exports('HasWerewolf', function(source)
    local data = GetPlayerData(source)
    return data and data.is_werewolf == 1
end)

-- Skills
exports('UnlockSkill', function(source, skillId)
    local data = GetPlayerData(source)
    if data.skills[skillId] then return end
    data.skills[skillId] = true
    UpdatePlayerData(data.citizenid, 'skills', data.skills)
end)

exports('HasSkill', function(source, skillId)
    local data = GetPlayerData(source)
    return data.skills[skillId] == true
end)

-- Animagus
exports('GetAnimagusAnimal', function(source)
    local data = GetPlayerData(source)
    return data.animagus_animal
end)

exports('SetAnimagusAnimal', function(source, animal)
    local data = GetPlayerData(source)
    data.animagus_animal = animal
    UpdatePlayerData(data.citizenid, 'animagus_animal', animal)
end)

-- Spell exports
exports('GetVampireSpells', function()
    return Config.VampireSpells or {}
end)

exports('GetAnimagusSpells', function()
    return Config.AnimagusSpells or {}
end)

exports('GetLycanSpells', function()
    return Config.LycanSpells or {}
end)

-- Debug exports for testing
exports('DebugVampireStatus', function(source)
    local data = GetPlayerData(source)
    print('[DEBUG] Vampire status for', source, ':', data and data.is_vampire or 'no data')
    return data and data.is_vampire == 1
end)

print('[fantasy_spells] Exports file loaded completely!')

-- Debug command for testing
RegisterCommand('debug_vampire', function(source, args)
    local targetId = tonumber(args[1]) or source
    local data = GetPlayerData(targetId)
    print('[DEBUG] Player', targetId, 'vampire status:', data and data.is_vampire or 'no data')
    print('[DEBUG] CitizenID:', data and data.citizenid or 'no data')
    
    if data then
        print('[DEBUG] Full data:', json.encode(data))
    end
end, false)
