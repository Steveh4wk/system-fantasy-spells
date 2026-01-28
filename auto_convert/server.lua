CreateThread(function()
    Wait(20000) -- Wait 20 seconds to ensure ox_inventory and MySQL are fully loaded
    print("[auto_convert] Starting QBcore inventory conversion...")
    
    -- Use oxmysql exports instead of requiring MySQL module
    local success, errorMsg = pcall(function()
        -- Try to get player data - adjust query based on actual table structure
        local players = exports.oxmysql:executeSync('SELECT citizenid, inventory FROM players')
        
        if not players then
            error("Failed to load players from database")
        end
        
        print(("[auto_convert] Found %d players to convert"):format(#players))

        for i = 1, #players do
            local inventory, slot = {}, 0
            local player = players[i]
            
            -- Check if player already has ox_inventory format
            if player.inventory then
                local existingInv = json.decode(player.inventory)
                if existingInv and type(existingInv) == "table" and existingInv[1] and existingInv[1].slot then
                    print(("[auto_convert] Player %s already has ox_inventory format, skipping"):format(player.citizenid))
                    goto continue
                end
            end

            -- Get inventory from players table (QBcore format)
            local items = player.inventory and json.decode(player.inventory) or {}

            -- Convert QBcore items structure (assuming {"itemname": amount, ...})
            for itemName, itemAmount in pairs(items) do
                if type(itemAmount) == "number" and itemAmount > 0 then
                    slot += 1
                    local itemInfo = {
                        slot = slot,
                        name = itemName,
                        count = itemAmount
                    }

                    inventory[slot] = itemInfo
                elseif type(itemAmount) == "table" and itemAmount.amount and itemAmount.amount > 0 then
                    -- In case it's {"itemname": {amount = x, info = ...}}
                    slot += 1
                    local itemInfo = {
                        slot = slot,
                        name = itemName,
                        count = itemAmount.amount
                    }

                    if itemAmount.info then
                        itemInfo.metadata = itemAmount.info
                    end

                    inventory[slot] = itemInfo
                end
            end
            
            -- Update the player's inventory
            exports.oxmysql:executeSync('UPDATE players SET inventory = ? WHERE citizenid = ?', {json.encode(inventory), player.citizenid})

            ::continue::
        end

        print("[auto_convert] QBcore inventory conversion completed!")
    end)
    
    if not success then
        print("[auto_convert] Error during conversion:", errorMsg or "Unknown error")
    end
end)