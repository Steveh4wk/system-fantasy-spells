local activeCooldowns = {}

function IsSpellReady(spellId)
    return not activeCooldowns[spellId] or activeCooldowns[spellId] < GetGameTimer()
end

function StartCooldown(spellId, seconds)
    activeCooldowns[spellId] = GetGameTimer() + (seconds * 1000)
end
