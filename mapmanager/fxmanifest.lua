fx_version 'cerulean'
game 'gta5'

author 'FiveM'
description 'Default map manager for FiveM.'
version '1.0.0'

-- What to run
server_script 'mapmanager.lua'

-- What to export
exports {
	'getCurrentMap',
	'getCurrentGameMode',
	'getGameModeName',
	'setGameMode',
	'switchMap',
	'switchingMaps',
	'getMapList'
}

-- What to provide
provide 'mapmanager'
