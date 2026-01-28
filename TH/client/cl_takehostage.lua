-----------------------------------------------------------------
-- Original TakeHostage by Robbster,creds for all the functions, this is an edit for qbcore
------------------------------------------------------------------
local QBCore = exports['qb-core']:GetCoreObject()

-- Hotkey F5 per takehostage
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 166) then -- F5 key
            callTakeHostage()
        end
    end
end)

local takeHostage = {
	InProgress = false,
	type = "",
	targetSrc = -1,
	targetPed = nil,
	isNPC = false,
	agressor = {
		animDict = "anim@gangops@hostage@",
		anim = "perp_idle",
		flag = 49,
	},
	hostage = {
		animDict = "anim@gangops@hostage@",
		anim = "victim_idle",
		attachX = -0.24,
		attachY = 0.11,
		attachZ = 0.0,
		flag = 49,
	}
}



CreateThread(function()
    exports['ox_target']:addGlobalPlayer({
        {
            icon = "fas fa-gun",
            label = "Take Hostage",
            onClick = function(data)
                callTakeHostage()
            end,
            distance = 3.0 
        }
    })
end)

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestEntity = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Controlla prima i giocatori reali
    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestEntity = targetPed
                closestDistance = distance
            end
        end
    end

    -- Se non trova giocatori, controlla gli NPC
    if closestDistance == -1 or closestDistance > radius then
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if ped ~= playerPed and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, 1) then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(pedCoords - playerCoords)
                if closestDistance == -1 or closestDistance > distance then
                    closestEntity = ped
                    closestDistance = distance
                end
            end
        end
    end

    if closestDistance ~= -1 and closestDistance <= radius then
        return closestEntity, IsPedAPlayer(closestEntity)
    else
        return nil, false
    end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end


function callTakeHostage()
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)

	-- Controlla se il giocatore ha un'arma in mano
	local currentWeapon = GetSelectedPedWeapon(PlayerPedId())
	if currentWeapon == `WEAPON_UNARMED` then
		QBCore.Functions.Notify('Devi avere un\'arma in mano per prendere un ostaggio', 'error', 7500)
		return
	end

	if not takeHostage.InProgress then			
		local closestEntity, isPlayer = GetClosestPlayer(3)
		if closestEntity then
			if isPlayer then
				-- È un giocatore reale
				local targetSrc = GetPlayerServerId(closestEntity)
				if targetSrc ~= -1 then
					SetCurrentPedWeapon(PlayerPedId(), currentWeapon, true)
					takeHostage.InProgress = true
					takeHostage.targetSrc = targetSrc
					TriggerServerEvent("TakeHostage:sync",targetSrc)
					ensureAnimDict(takeHostage.agressor.animDict)
					takeHostage.type = "agressor"
				else
					QBCore.Functions.Notify('Nessun giocatore nelle vicinanze', 'error', 7500)
				end
			else
				-- È un NPC
				SetCurrentPedWeapon(PlayerPedId(), currentWeapon, true)
				takeHostage.InProgress = true
				takeHostage.targetPed = closestEntity
				takeHostage.isNPC = true
				ensureAnimDict(takeHostage.agressor.animDict)
				takeHostage.type = "agressor"
				
				-- Applica l'animazione all'NPC
				ensureAnimDict(takeHostage.hostage.animDict)
				AttachEntityToEntity(closestEntity, PlayerPedId(), 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
				TaskPlayAnim(closestEntity, takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			end
		else
			QBCore.Functions.Notify('Nessuno nelle vicinanze', 'error', 7500)
		end
	end
end 

RegisterNetEvent("TakeHostage:syncTarget")
AddEventHandler("TakeHostage:syncTarget", function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	takeHostage.InProgress = true
	ensureAnimDict(takeHostage.hostage.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	takeHostage.type = "hostage" 
end)

RegisterNetEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function()
	QBCore.Functions.Notify("You Got Free'd!!", 'success', 7500)
	takeHostage.InProgress = false 
	takeHostage.type = ""
	DetachEntity(PlayerPedId(), true, false)
	ensureAnimDict("reaction@shove")
	TaskPlayAnim(PlayerPedId(), "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	Wait(250)
	ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = ""
	SetEntityHealth(PlayerPedId(),0)
	DetachEntity(PlayerPedId(), true, false)
	ensureAnimDict("anim@gangops@hostage@")
	TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("TakeHostage:cl_stop")
AddEventHandler("TakeHostage:cl_stop", function()
	takeHostage.InProgress = false
	takeHostage.type = "" 
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if takeHostage.type == "agressor" then
			if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				TaskPlayAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			end
		elseif takeHostage.type == "hostage" then
			if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				TaskPlayAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
				QBCore.Functions.Notify('YOU HAVE BEEN TAKEN HOSTAGE!!', 'error', 2500)	
			end
		end
		Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do 
		if takeHostage.type == "agressor" then
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,21,true) -- disable sprint
			DisablePlayerFiring(PlayerPedId(),true)
			exports['qb-core']:DrawText(Config.Text)             

			if IsEntityDead(PlayerPedId()) then	
				takeHostage.type = ""
				takeHostage.InProgress = false
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				if takeHostage.isNPC and takeHostage.targetPed then
					-- Rilascia l'NPC
					DetachEntity(takeHostage.targetPed, true, false)
					ClearPedTasks(takeHostage.targetPed)
				else
					TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
				end
			end 

			if IsDisabledControlJustPressed(0,47) then
				exports['qb-core']:HideText() --release	
				takeHostage.type = ""
				takeHostage.InProgress = false 
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				if takeHostage.isNPC and takeHostage.targetPed then
					-- Rilascia l'NPC
					DetachEntity(takeHostage.targetPed, true, false)
					ClearPedTasks(takeHostage.targetPed)
					takeHostage.isNPC = false
					takeHostage.targetPed = nil
				else
					TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
				end
			elseif IsDisabledControlJustPressed(0,74) then
				exports['qb-core']:HideText() --kill 			
				takeHostage.type = ""
				takeHostage.InProgress = false 		
				ensureAnimDict("anim@gangops@hostage@")
				TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				if takeHostage.isNPC and takeHostage.targetPed then
					-- Uccide l'NPC
					SetEntityHealth(takeHostage.targetPed, 0)
					DetachEntity(takeHostage.targetPed, true, false)
					ensureAnimDict("anim@gangops@hostage@")
					TaskPlayAnim(takeHostage.targetPed, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
					takeHostage.isNPC = false
					takeHostage.targetPed = nil
				else
					TriggerServerEvent("TakeHostage:killHostage", takeHostage.targetSrc)
					TriggerServerEvent("TakeHostage:stop",takeHostage.targetSrc)
				end
				Wait(100)
				SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0)
			end
		elseif takeHostage.type == "hostage" then 
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		end
		Wait(0)
	end
end)
