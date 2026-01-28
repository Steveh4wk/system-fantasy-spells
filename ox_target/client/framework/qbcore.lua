-- QBcore framework bridge for ox_target
if not lib.checkDependency('qb-core', '1.0.0', true) then return end

local QBCore = exports['qb-core']:GetCoreObject()
local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local ok, data = pcall(function() return QBCore.Functions.GetPlayerData() end)
    if not ok or not data or not data.job then return false end

    local jobname = data.job.name

    if type(filter) == 'string' then
        return jobname == filter
    elseif type(filter) == 'table' then
        if #filter > 0 then
            for i = 1, #filter do if filter[i] == jobname then return true end end
        else
            for k, _ in pairs(filter) do if k == jobname then return true end end
        end
    end

    return false
end
