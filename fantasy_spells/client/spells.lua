RegisterCommand('spells', function()
    local options = {}

    if exports['fantasy_spells']:IsVampire(PlayerId()) then
        for _, spell in pairs(Spells.vampire) do
            if exports['fantasy_spells']:HasSkill(PlayerId(), spell.requiredSkill) then
                options[#options+1] = {
                    title = spell.label,
                    onSelect = function()
                        if not IsSpellReady(spell.id) then
                            lib.notify({ description = 'Spell in cooldown', type = 'error' })
                            return
                        end

                        spell.cast()
                        StartCooldown(spell.id, spell.cooldown)
                        lib.notify({ description = 'Spell lanciata' })
                    end
                }
            end
        end
    end

    lib.registerContext({
        id = 'fantasy_spell_menu',
        title = 'Grimorio',
        options = options
    })

    lib.showContext('fantasy_spell_menu')
end)
