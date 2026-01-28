local QBCore = exports['qb-core']:GetCoreObject()
local PlayerDataCache = {} -- cache lato server

-- Crea la tabella principale se non esiste
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS fantasy_players (
            citizenid VARCHAR(60) PRIMARY KEY,
            is_vampire TINYINT DEFAULT 0,
            is_werewolf TINYINT DEFAULT 0,
            animagus_animal VARCHAR(50),
            skills TEXT
        )
    ]])
end)

-- Ritorna citizenid
local function GetCitizenId(source)
    local player = QBCore.Functions.GetPlayer(source)
    return player and player.PlayerData.citizenid
end

-- Carica i dati del player in cache
local function LoadPlayerData(source)
    local citizenId = GetCitizenId(source)
    if not citizenId then return end

    local data = MySQL.single.await(
        'SELECT * FROM fantasy_players WHERE citizenid = ?',
        { citizenId }
    )

    if not data then
        -- crea riga se non esiste
        MySQL.insert.await(
            'INSERT INTO fantasy_players (citizenid, skills) VALUES (?, ?)',
            { citizenId, json.encode({}) }
        )
        data = { citizenid = citizenId, is_vampire = 0, is_werewolf = 0, animagus_animal = nil, skills = '{}' }
    end

    -- decodifica skills
    data.skills = json.decode(data.skills or '{}')
    PlayerDataCache[citizenId] = data
    return data
end

-- Aggiorna DB + cache 
local function UpdatePlayerData(citizenId, column, value)
    if not PlayerDataCache[citizenId] then return end
    PlayerDataCache[citizenId][column] = value

    if column == 'skills' then
        value = json.encode(value)
    end

    MySQL.update('UPDATE fantasy_players SET '..column..' = ? WHERE citizenid = ?', { value, citizenId })
end

-- caricamento player
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    LoadPlayerData(player.PlayerData.source)
end)

-- Pulizia cache al disconnect
AddEventHandler('QBCore:Server:PlayerUnload', function(playerId)
    local citizenId = GetCitizenId(playerId)
    if citizenId then PlayerDataCache[citizenId] = nil end
end)
-- helper
function GetPlayerData(source)
    local citizenId = GetCitizenId(source)
    if not citizenId then return end
    return PlayerDataCache[citizenId] or LoadPlayerData(source)
end
