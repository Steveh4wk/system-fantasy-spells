-- Fantasy Spells Exports
local QBCore = exports['qb-core']:GetCoreObject()

print('[fantasy_spells] Exports loaded successfully!')

-- Test export
exports('TestExport', function()
    print('[fantasy_spells] TestExport called!')
    return 'working'
end)

-- Vampire exports
exports('HasVampire', function(source)
    print('[fantasy_spells] HasVampire called for source:', source)
    local data = GetPlayerData(source)
    return data and data.is_vampire == 1
end)

exports('IsVampire', function(source)
    local data = GetPlayerData(source)
    return data and data.is_vampire == 1
end)

exports('UnlockVampire', function(source)
    local data = GetPlayerData(source)
    if data.is_vampire == 1 then return end
    UpdatePlayerData(data.citizenid, 'is_vampire', 1)
end)

-- Werewolf exports
exports('HasWerewolf', function(source)
    local data = GetPlayerData(source)
    return data and data.is_werewolf == 1
end)

exports('IsWerewolf', function(source)
    local data = GetPlayerData(source)
    return data and data.is_werewolf == 1
end)

exports('UnlockWerewolf', function(source)
    local data = GetPlayerData(source)
    if data.is_werewolf == 1 then return end
    UpdatePlayerData(data.citizenid, 'is_werewolf', 1)
end)

-- Skills
exports('HasSkill', function(source, skillId)
    local data = GetPlayerData(source)
    return data.skills[skillId] == true
end)

exports('UnlockSkill', function(source, skillId)
    local data = GetPlayerData(source)
    if data.skills[skillId] then return end
    data.skills[skillId] = true
    UpdatePlayerData(data.citizenid, 'skills', data.skills)
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

-- Spells
exports('GetVampireSpells', function()
    return Config.VampireSpells or {}
end)

exports('GetAnimagusSpells', function()
    return Config.AnimagusSpells or {}
end)

-- Callbacks for client-side access
QBCore.Functions.CreateCallback('fantasy_spells:HasVampire', function(source, cb)
    local data = GetPlayerData(source)
    cb(data and data.is_vampire == 1)
end)

QBCore.Functions.CreateCallback('fantasy_spells:HasWerewolf', function(source, cb)
    local data = GetPlayerData(source)
    cb(data and data.is_werewolf == 1)
end)

QBCore.Functions.CreateCallback('fantasy_spells:GetVampireSpells', function(source, cb)
    cb(Config.VampireSpells or {})
end)

QBCore.Functions.CreateCallback('fantasy_spells:GetAnimagusSpells', function(source, cb)
    cb(Config.AnimagusSpells or {})
end)

-- Event handlers for client communication
RegisterServerEvent('fantasy_spells:server:HasVampire')
AddEventHandler('fantasy_spells:server:HasVampire', function()
    local source = source
    local data = GetPlayerData(source)
    TriggerClientEvent('fantasy_spells:client:HasVampireResponse', source, data and data.is_vampire == 1)
end)

RegisterServerEvent('fantasy_spells:server:GetVampireSpells')
AddEventHandler('fantasy_spells:server:GetVampireSpells', function()
    local source = source
    TriggerClientEvent('fantasy_spells:client:GetVampireSpellsResponse', source, Config.VampireSpells or {})
end)

RegisterServerEvent('fantasy_spells:server:GetAnimagusSpells')
AddEventHandler('fantasy_spells:server:GetAnimagusSpells', function()
    local source = source
    TriggerClientEvent('fantasy_spells:client:GetAnimagusSpellsResponse', source, Config.AnimagusSpells or {})
end)
