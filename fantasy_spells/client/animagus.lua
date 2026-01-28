local originalSkin = nil
local inAnimalForm = false

RegisterCommand('animagus', function()
    --------------------
    -- BLOCCO SKILL
    ----------------------
    if not exports['fantasy_spells']:HasSkill(PlayerId(), 'unlock_animagus_transform') then
        lib.notify({ description = 'Non controlli ancora il potere Animagus', type = 'error' })
        return
    end

    local animal = exports['fantasy_spells']:GetAnimagusAnimal(PlayerId())

    if not animal then
        local options = {}

        for _, data in pairs(Config.AnimagusAnimals) do
            options[#options+1] = {
                title = data.label,
                onSelect = function()
                    exports['fantasy_spells']:SetAnimagusAnimal(PlayerId(), data.model)
                    Transform(data.model)
                end
            }
        end

        lib.registerContext({
            id = 'animagus_select',
            title = 'Scegli il tuo Animagus',
            options = options
        })

        lib.showContext('animagus_select')
        return
    end

    Transform(animal)
end)

function Transform(model)
    if not inAnimalForm then
        originalSkin = exports['qb-clothing']:GetCurrentOutfit()
    end

    lib.requestModel(model)
    SetPlayerModel(PlayerId(), joaat(model))
    inAnimalForm = true
end

RegisterCommand('human', function()
    if originalSkin and inAnimalForm then
        exports['qb-clothing']:SetOutfit(originalSkin)
        inAnimalForm = false
    end
end)
