fx_version 'cerulean'
game 'gta5'

author 'Stefano Luciano Corp'
description 'Annuario per Astral RP'
version '1.0.1'

-- What to run
client_script 'client/*.lua'
server_script 'server/*.lua'

-- What to export
exports {
	'OpenBook',
	'CloseBook'
}

-- Client exports
client_exports {
	'OpenBook',
	'CloseBook'
}

-- Dependencies
dependency 'ox_lib'

-- NUI files
ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/index.css',
    'nui/index.js',
    'nui/turn.min.js',
    'nui/img/*.png'
}