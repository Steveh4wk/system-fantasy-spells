CreatureSystem = {
    states = {},
    originalState = nil
}

function CreatureSystem.GetCreatureState(key)
    return CreatureSystem.states[key] or false
end

function CreatureSystem.SetCreatureState(key, value)
    CreatureSystem.states[key] = value
end

function CreatureSystem.RestoreOriginalState()
    if CreatureSystem.originalState then
        -- Ripristina il modello originale
        local playerId = PlayerId()
        local hash = CreatureSystem.originalState.hash
        
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        
        SetPlayerModel(playerId, hash)
        SetModelAsNoLongerNeeded(hash)
        
        -- Ripristina componenti se salvati
        if CreatureSystem.originalState.components then
            local playerPed = PlayerPedId()
            for i, component in ipairs(CreatureSystem.originalState.components) do
                SetPedComponentVariation(playerPed, component.drawableId, component.textureId, component.paletteId)
            end
        end
        
        return true
    end
    
    -- Fallback: modello umano base
    local playerId = PlayerId()
    local defaultModel = 'mp_m_freemode_01'
    local hash = joaat(defaultModel)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
    
    SetPlayerModel(playerId, hash)
    SetModelAsNoLongerNeeded(hash)
    
    return true
end

function CreatureSystem.SaveOriginalState()
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)
    
    CreatureSystem.originalState = {
        model = model,
        hash = model,
        components = {}
    }
    
    -- Salva componenti principali
    for i = 0, 11 do
        table.insert(CreatureSystem.originalState.components, {
            drawableId = GetPedDrawableVariation(playerPed, i),
            textureId = GetPedTextureVariation(playerPed, i),
            paletteId = GetPedPaletteVariation(playerPed, i)
        })
    end
end

function CreatureSystem.ResetCreatures()
    CreatureSystem.states = {}
end

-- Export funzioni per uso esterno
exports('GetCreatureState', CreatureSystem.GetCreatureState)
exports('SetCreatureState', CreatureSystem.SetCreatureState)
exports('RestoreOriginalState', CreatureSystem.RestoreOriginalState)
exports('SaveOriginalState', CreatureSystem.SaveOriginalState)
exports('ResetCreatures', CreatureSystem.ResetCreatures)