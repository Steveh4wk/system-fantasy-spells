local currentMap = 'default'
local currentGametype = 'freeroam'
local isSwitching = false

local maps = {
	['default'] = {
		gametypes = {
			['freeroam'] = {
				['name'] = 'Free Roam',
				['slots'] = 30
			}
		}
	}
}

function getCurrentMap()
	return currentMap
end

function getCurrentGameMode()
	return currentGametype
end

function getGameModeName()
	return maps[currentMap].gametypes[currentGametype].name
end

function setGameMode(gametype)
	if not isSwitching then
		currentGametype = gametype
	end
end

function switchMap(map, gametype)
	if not isSwitching then
		isSwitching = true
		
		currentMap = map
		currentGametype = gametype
		
		TriggerClientEvent('onClientMapSwitch', map, gametype)
		
		isSwitching = false
	end
end

function switchingMaps()
	return isSwitching
end

function getMapList()
	return maps
end

exports('getCurrentMap', getCurrentMap)
exports('getCurrentGameMode', getCurrentGameMode)
exports('getGameModeName', getGameModeName)
exports('setGameMode', setGameMode)
exports('switchMap', switchMap)
exports('switchingMaps', switchingMaps)
exports('getMapList', getMapList)

RegisterServerEvent('mapmanager:switchMap')
AddEventHandler('mapmanager:switchMap', function(map, gametype)
	switchMap(map, gametype)
end)
