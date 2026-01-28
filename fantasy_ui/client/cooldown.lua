-- Stefano Luciano Corp
-- Fantasy UI - Gestione cooldown delle spell
-- Funziona con fantasy_spells
-- Exportable per altri client

local spellCooldowns = {}

-- Controlla se la spell è in cooldown
local function IsOnCooldown(spellId)
    return spellCooldowns[spellId] and spellCooldowns[spellId] > GetGameTimer()
end

-- Avvia cooldown per una spell
local function StartCooldown(spellId, timeSec)
    spellCooldowns[spellId] = GetGameTimer() + (timeSec * 1000)
end

-- Export per verificare se una spell può essere lanciata
exports('CanCastSpell', function(spellId)
    return not IsOnCooldown(spellId)
end)

-- Export per iniziare cooldown di una spell
exports('StartCooldown', function(spellId, timeSec)
    StartCooldown(spellId, timeSec)
end)
