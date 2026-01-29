-- ==========================================================
-- Fantasy Peds Items for ox_inventory
-- Configurazione item per Vampiri e Licantropi
-- Autore: Stefano Luciano Corp
-- ==========================================================

local items = {

    -- Item Sangue per Vampiri
    ['sangue'] = {
        label = 'Sangue',
        weight = 0.100,
        description = 'Fiaschetta di sangue puro per vampiri',
        image = 'sangue.png',
        client = {
            status = { hunger = 40, thirst = 40 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle', flag = 49 },
            prop = { model = `prop_blood_bag`, pos = vec3(0.0,0.0,0.0), rot = vec3(0.0, 0.0, 0.0) },
            usetime = 2000,
        },
        server = {
            export = 'fantasy_peds.useItem'
        }
    },

    -- Item Carne Cruda per Licantropi
    ['raw_meat'] = {
        label = 'Carne Cruda',
        weight = 0.100,
        description = 'Carne cruda adatta ai licantropi',
        client = {
            status = { hunger = 25 },
            anim = { dict = 'amb@world_human_gardener_plant@male@enter', clip = 'enter', flag = 49 },
            usetime = 2000,
        },
        server = {
            export = 'fantasy_peds.useItem'
        }
    },

    -- Item Acqua per Licantropi
    ['water_bottle'] = {
        label = 'Acqua',
        weight = 0.100,
        description = 'Bottiglia d\'acqua pura',
        client = {
            status = { thirst = 25 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle', flag = 49 },
            prop = { model = `prop_ld_water_bottle`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
            usetime = 2000,
        },
        server = {
            export = 'fantasy_peds.useItem'
        }
    }

}

return items
