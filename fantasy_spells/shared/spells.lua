Spells = {
    vampire = {
        {
            id = 'blood_vision',
            label = 'Visione di Sangue',
            cooldown = 30,
            requiredSkill = 'unlock_vampire_spells',
            cast = function()
                SetNightvision(true)
            end
        }
    },

    werewolf = {
        {
            id = 'bestial_force',
            label = 'Forza Bestiale',
            cooldown = 45,
            requiredSkill = 'unlock_werewolf_spells',
            cast = function()
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.3)
            end
        }
    }
}
