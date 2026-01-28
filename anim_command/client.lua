RegisterCommand("anim", function(source, args, raw)
    local abbr = table.concat(args, " "):lower()
    if abbr == "" then return end

    local anims = {
        ["shove"] = {"reaction@shove", "shove_var_a"},
        ["shoved"] = {"reaction@shove", "shoved_back"},
        ["hostage_perp"] = {"anim@gangops@hostage@", "perp_fail"},
        ["hostage_victim"] = {"anim@gangops@hostage@", "victim_fail"},
        ["keyfob"] = {"anim@mp_player_intmenu@key_fob@", "fob_click"},
        ["pill"] = {"mp_suicide", "pill"},
        ["pistol"] = {"mp_suicide", "pistol"},
        ["phone"] = {"cellphone@", "cellphone_text_read_base"},
        ["dog_idle"] = {"creatures@rottweiler@amb@world_dog_barking@idle_a", "idle_b"},
        ["sit"] = {"anim@heists@prison_heistunfinished_biz@player1", "player1_biz_anim_finishes_p1"},
        ["dance"] = {"anim@mp_player_intcelebrationmale@dj", "dj"},
        ["stop"] = "stop"
    }

    if anims[abbr] then
        if anims[abbr] == "stop" then
            ClearPedTasks(PlayerPedId())
        else
            local dict = anims[abbr][1]
            local name = anims[abbr][2]
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(0)
            end
            TaskPlayAnim(PlayerPedId(), dict, name, 8.0, -8.0, -1, 1, 0, false, false, false)
        end
    else
        -- Allow playing any animation by dict name
        if #args >= 2 then
            local dict = args[1]
            table.remove(args, 1)
            local name = table.concat(args, " ")
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(0)
            end
            TaskPlayAnim(PlayerPedId(), dict, name, 8.0, -8.0, -1, 1, 0, false, false, false)
        end
    end
end, false)