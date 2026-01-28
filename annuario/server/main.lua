-- Server-side annuario logic
-- Load configuration directly
Config = {
    Books = {
        ['annuario'] = {
            ['pages'] = {
                { pageName = "COPERTINA", type = 'hard', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "COPERTINA_END", type = 'hard', source = 'local' },
            },
            ['prop'] = 'book',
            ['size'] = {
                ['width'] = 720,
                ['height'] = 600,
            },
        },
    },
}

print('[annuario] Config loaded successfully')

-- Global variable to track book usage
local bookUsers = {}

-- Open book for player
RegisterNetEvent('annuario:server:openBook')
AddEventHandler('annuario:server:openBook', function()
    local source = source
    print('[annuario] Server received openBook request from: ' .. GetPlayerName(source))
    
    -- Check if player is already using a book
    if bookUsers[source] then
        print('[annuario] Player is already using a book')
        return
    end
    
    bookUsers[source] = true
    
    -- Send book configuration to client
    local bookConfig = Config.Books['annuario']
    TriggerClientEvent('annuario:client:openBook', source, bookConfig)
end)

-- Close book for player
RegisterNetEvent('annuario:server:closeBook')
AddEventHandler('annuario:server:closeBook', function()
    local source = source
    print('[annuario] Server received closeBook request from: ' .. GetPlayerName(source))
    
    bookUsers[source] = nil
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    bookUsers[source] = nil
end)

-- Exports
exports('OpenBook', function(source)
    TriggerClientEvent('annuario:client:openBook', source, Config.Books['annuario'])
end)

exports('CloseBook', function(source)
    TriggerClientEvent('annuario:client:closeBook', source)
end)

-- Legacy export for compatibility
exports('openBook', function(source)
    TriggerClientEvent('annuario:client:openBook', source, Config.Books['annuario'])
end)

print('[annuario] Server book system loaded')

-- Give annuario to new players
AddEventHandler('playerConnecting', function()
	local source = source
	
	Citizen.SetTimeout(5000, function()
		if GetPlayerName(source) then
			-- Check if player already has annuario
			local inventory = exports.ox_inventory:GetInventory(source)
			
			local hasBook = false
			if inventory and inventory.items then
				for _, item in ipairs(inventory.items) do
					if item.name == 'annuario' then
						hasBook = true
						break
					end
				end
			end
			
			-- Add annuario if player doesn't have it
			if not hasBook then
				exports.ox_inventory:AddItem(source, 'annuario', 1)
				print('[annuario] Given annuario to player: ' .. GetPlayerName(source))
			end
		end
	end)
end)