-- Stefano Luciano Corp
-- Fantasy UI - Menu spell Vampiro e Animagus
-- Usa solo exports di fantasy_spells

-- Funzione helper per creare opzioni menu Lycan
local function CreateLycanSpellOption(spellId, spell)
    return {
        title = '🐺 ' .. spell.label,
        description = spell.description or 'Abilità Lycan',
        onSelect = function()
            if exports['fantasy_ui']:CanCastSpell(spellId) then
                spell.action()  -- Azione della spell
                exports['fantasy_ui']:StartCooldown(spellId, spell.cooldown)
            else
                lib.notify({title='Lycan', description='Abilità in cooldown!', type='error'})
            end
        end
    }
end

-- Funzione helper per creare opzioni menu
local function CreateSpellOption(spellId, spell)
    return {
        title = spell.label,
        onSelect = function()
            if exports['fantasy_ui']:CanCastSpell(spellId) then
                spell.action()  -- Azione della spell
                exports['fantasy_ui']:StartCooldown(spellId, spell.cooldown)
            else
                lib.notify({title='Fantasy UI', description='Spell in cooldown!', type='error'})
            end
        end
    }
end

-- Comando per aprire il menu spell
RegisterCommand('spells', function()
    local options = {}

    local playerId = PlayerId()

    -- Controlla se è Vampiro usando eventi
    TriggerServerEvent('fantasy_spells:server:CheckVampire')

    local vampireHandler = AddEventHandler('fantasy_spells:client:VampireCheckResult', function(isVampire)
        RemoveEventHandler(vampireHandler)

        if isVampire then
            TriggerServerEvent('fantasy_spells:server:GetVampireSpells')

            local spellHandler = AddEventHandler('fantasy_spells:client:VampireSpellsResult', function(vampireSpells)
                RemoveEventHandler(spellHandler)

                for spellId, spell in pairs(vampireSpells) do
                    options[#options+1] = CreateSpellOption(spellId, spell)
                end

                -- Controlla Lycan
                TriggerServerEvent('fantasy_spells:server:CheckWerewolf')

                local lycanHandler = AddEventHandler('fantasy_spells:client:WerewolfCheckResult', function(isWerewolf)
                    RemoveEventHandler(lycanHandler)

                    if isWerewolf then
                        TriggerServerEvent('fantasy_spells:server:GetLycanSpells')

                        local lycanSpellHandler = AddEventHandler('fantasy_spells:client:LycanSpellsResult', function(lycanSpells)
                            RemoveEventHandler(lycanSpellHandler)

                            for spellId, spell in pairs(lycanSpells) do
                                options[#options+1] = CreateLycanSpellOption(spellId, spell)
                            end

                            checkAnimagus()
                        end)
                    else
                        checkAnimagus()
                    end

                    function checkAnimagus()
                        -- Controlla Animagus
                        TriggerServerEvent('fantasy_spells:server:GetAnimagusAnimal')

                        local animagusHandler = AddEventHandler('fantasy_spells:client:AnimagusAnimalResult', function(animagusAnimal)
                            RemoveEventHandler(animagusHandler)

                            if animagusAnimal then
                                TriggerServerEvent('fantasy_spells:server:GetAnimagusSpells')

                                local animagusSpellHandler = AddEventHandler('fantasy_spells:client:AnimagusSpellsResult', function(animagusSpells)
                                    RemoveEventHandler(animagusSpellHandler)

                                    for spellId, spell in pairs(animagusSpells) do
                                        options[#options+1] = CreateSpellOption(spellId, spell)
                                    end

                                    showMenu()
                                end)
                            else
                                showMenu()
                            end
                        end)
                    end
                end)
            end)
        else
            -- Controlla Lycan se non è vampiro
            TriggerServerEvent('fantasy_spells:server:CheckWerewolf')

            local lycanHandler = AddEventHandler('fantasy_spells:client:WerewolfCheckResult', function(isWerewolf)
                RemoveEventHandler(lycanHandler)

                if isWerewolf then
                    TriggerServerEvent('fantasy_spells:server:GetLycanSpells')

                    local lycanSpellHandler = AddEventHandler('fantasy_spells:client:LycanSpellsResult', function(lycanSpells)
                        RemoveEventHandler(lycanSpellHandler)

                        for spellId, spell in pairs(lycanSpells) do
                            options[#options+1] = CreateLycanSpellOption(spellId, spell)
                        end

                        checkAnimagus()
                    end)
                else
                    checkAnimagus()
                end

                function checkAnimagus()
                    -- Controlla solo Animagus
                    TriggerServerEvent('fantasy_spells:server:GetAnimagusAnimal')

                    local animagusHandler = AddEventHandler('fantasy_spells:client:AnimagusAnimalResult', function(animagusAnimal)
                        RemoveEventHandler(animagusHandler)

                        if animagusAnimal then
                            TriggerServerEvent('fantasy_spells:server:GetAnimagusSpells')

                            local animagusSpellHandler = AddEventHandler('fantasy_spells:client:AnimagusSpellsResult', function(animagusSpells)
                                RemoveEventHandler(animagusSpellHandler)

                                for spellId, spell in pairs(animagusSpells) do
                                    options[#options+1] = CreateSpellOption(spellId, spell)
                                end

                                showMenu()
                            end)
                        else
                            showMenu()
                        end
                    end)
                end
            end)
        end
        
        function showMenu()
            if #options == 0 then
                lib.notify({title='Fantasy UI', description='Nessuna spell disponibile!', type='error'})
                return
            end

            lib.registerContext({
                id = 'spell_menu',
                title = 'Grimorio',
                options = options
            })

            lib.showContext('spell_menu')
        end
    end)
end)
