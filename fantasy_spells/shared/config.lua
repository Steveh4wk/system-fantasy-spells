Config = {}

Config.AnimagusAnimals = {
    { label = 'Gatto', model = 'a_c_cat_01' },
    { label = 'Lupo', model = 'a_c_wolf' },
    { label = 'Aquila', model = 'a_c_chickenhawk' },
    { label = 'Cervo', model = 'a_c_deer' }
}

-- Spell Vampiro
Config.VampireSpells = {
    blood_vision = {
        id = 'blood_vision',
        label = 'Visione di Sangue',
        cooldown = 30,
        description = 'Attiva la visione notturna per vedere meglio al buio',
        action = function()
            SetNightvision(true)
            lib.notify({title='Vampiro', description='Visione di Sangue attivata!', type='success'})
            
            -- Disattiva dopo 30 secondi usando un timer
            SetTimeout(30000, function()
                SetNightvision(false)
                lib.notify({title='Vampiro', description='Visione di Sangue disattivata', type='info'})
            end)
        end
    },
    
    blood_speed = {
        id = 'blood_speed',
        label = 'Velocità Sanguigna',
        cooldown = 60,
        description = 'Aumenta la velocità di movimento per 15 secondi',
        action = function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.5)
            lib.notify({title='Vampiro', description='Velocità Sanguigna attivata!', type='success'})
            
            -- Ripristina velocità dopo 15 secondi
            SetTimeout(15000, function()
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                lib.notify({title='Vampiro', description='Velocità Sanguigna terminata', type='info'})
            end)
        end
    },
    
    vampire_heal = {
        id = 'vampire_heal',
        label = 'Rigenerazione Vampirica',
        cooldown = 120,
        description = 'Cura parzialmente la salute',
        action = function()
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local newHealth = math.min(health + 50, 200)
            SetEntityHealth(ped, newHealth)
            
            lib.notify({title='Vampiro', description='Curato di ' .. (newHealth - health) .. ' HP!', type='success'})
        end
    },
    
    shadow_cloak = {
        id = 'shadow_cloak',
        label = 'Manto d\'Ombra',
        cooldown = 180,
        description = 'Diventa invisibile per 10 secondi',
        action = function()
            local ped = PlayerPedId()
            SetEntityVisible(ped, false, 0)
            lib.notify({title='Vampiro', description='Manto d\'Ombra attivato!', type='success'})
            
            -- Ripristina visibilità dopo 10 secondi
            SetTimeout(10000, function()
                SetEntityVisible(ped, true, 0)
                lib.notify({title='Vampiro', description='Manto d\'Ombra terminato', type='info'})
            end)
        end
    },
    
    dark_strength = {
        id = 'dark_strength',
        label = 'Forza Oscura',
        cooldown = 90,
        description = 'Aumenta la forza fisica per 20 secondi',
        action = function()
            local ped = PlayerPedId()
            SetMeleeWeaponDamageModifier(2.0)
            lib.notify({title='Vampiro', description='Forza Oscura attivata!', type='success'})
            
            -- Ripristina forza dopo 20 secondi
            SetTimeout(20000, function()
                SetMeleeWeaponDamageModifier(1.0)
                lib.notify({title='Vampiro', description='Forza Oscura terminata', type='info'})
            end)
        end
    },
    
    blood_jump = {
        id = 'blood_jump',
        label = 'Salto Sanguigno',
        cooldown = 45,
        description = 'Salto potenziato con danno all\'atterraggio',
        action = function()
            local ped = PlayerPedId()
            SetSuperJumpThisFrame(PlayerId())
            lib.notify({title='Vampiro', description='Salto Sanguigno attivato!', type='success'})
            
            -- Effetto speciale
            ApplyForceToEntityCenterOfMass(ped, 0, 0.0, 15.0, 0.0, 0.0, 0.0, 1, false, true, true, false)
        end
    }
}

-- Spell Animagus
Config.AnimagusSpells = {
    animal_senses = {
        id = 'animal_senses',
        label = 'Sensi Animali',
        cooldown = 45,
        description = 'Migliora i sensi per 20 secondi',
        action = function()
            SetAudioFlag('PlayerSprintAudio', true)
            lib.notify({title='Animagus', description='Sensi Animali attivati!', type='success'})
            
            -- Disattiva dopo 20 secondi
            SetTimeout(20000, function()
                SetAudioFlag('PlayerSprintAudio', false)
                lib.notify({title='Animagus', description='Sensi Animali terminati', type='info'})
            end)
        end
    },
    
    animal_speed = {
        id = 'animal_speed',
        label = 'Velocità Animale',
        cooldown = 30,
        description = 'Aumenta la velocità nella forma animale',
        action = function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.3)
            lib.notify({title='Animagus', description='Velocità Animale attivata!', type='success'})
            
            -- Ripristina dopo 20 secondi
            SetTimeout(20000, function()
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                lib.notify({title='Animagus', description='Velocità Animale terminata', type='info'})
            end)
        end
    }
}
