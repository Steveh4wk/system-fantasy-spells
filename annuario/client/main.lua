-- Client-side annuario logic
local isOpen = false
local bookProp = nil

-- Export function for ox_inventory
exports('OpenBook', function()
    if not isOpen then
        TriggerServerEvent('annuario:server:openBook')
    end
end)

-- Open book event (from server or direct from inventory)
RegisterNetEvent('annuario:client:openBook')
AddEventHandler('annuario:client:openBook', function(bookConfig)
    print('[annuario] Received openBook event with config:', json.encode(bookConfig))
    
    -- Check if this is item data from inventory (has item properties) or book config
    if bookConfig and bookConfig.name == 'annuario' then
        -- This is item data from inventory, use default book config
        bookConfig = {
            pages = {
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
            prop = 'book',
            size = {
                width = 720,
                height = 600,
            },
        }
    end
    
    if not bookConfig or not bookConfig.pages then
        print('[annuario] Config not found, using fallback')
        bookConfig = {
            pages = {
                { pageName = "COPERTINA", type = 'hard', source = 'local' },
                { pageName = "PAGINA_VUOTA", type = 'normal', source = 'local' },
                { pageName = "COPERTINA_END", type = 'hard', source = 'local' },
            },
            prop = 'book',
            size = { width = 720, height = 600 },
        }
    end
    
    isOpen = true
    SetNuiFocus(true, true)
    
    -- Add book prop to player's hand
    local ped = PlayerPedId()
    local ped_coords = GetEntityCoords(ped)
    
    -- Add book prop to player's hand
    local propName = `prop_novel_01`
    RequestModel(propName)
    while not HasModelLoaded(propName) do
        Wait(1)
    end
    bookProp = CreateObject(propName, ped_coords.x, ped_coords.y, ped_coords.z, true, true, true)
    AttachEntityToEntity(bookProp, ped, GetPedBoneIndex(ped, 6286), 0.15, 0.03, -0.065, 0.0, 180.0, 90.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(propName)
    
    -- Play reading animation
    RequestAnimDict('cellphone@')
    while not HasAnimDictLoaded('cellphone@') do
        Wait(1)
    end
    TaskPlayAnim(PlayerPedId(), 'cellphone@', 'cellphone_text_read_base', 1.0, -1.0, 10000, 49, 1, false, false, false)
    RemoveAnimDict('cellphone@')
    
    -- Send NUI message with book configuration
    SendNUIMessage({
        show = true,
        book = 'annuario',
        pages = bookConfig.pages,
        size = bookConfig.size,
        discordChannelId = "",
    })
end)

-- Close book event
RegisterNetEvent('annuario:client:closeBook')
AddEventHandler('annuario:client:closeBook', function()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ show = false })
    
    -- Clear animation and remove prop
    ClearPedSecondaryTask(PlayerPedId())
    Wait(100)
    if bookProp then
        SetEntityAsMissionEntity(bookProp)
        DeleteObject(bookProp)
        bookProp = nil
    end
end)

-- NUI callback for closing book
RegisterNUICallback('chiudi', function(data, cb)
    print('[annuario] Closing book via NUI callback')
    local ped = PlayerPedId()
    
    -- Clear animation and remove prop
    ClearPedSecondaryTask(ped)
    Wait(100)
    if bookProp then
        SetEntityAsMissionEntity(bookProp)
        DeleteObject(bookProp)
        bookProp = nil
    end
    
    SetNuiFocus(false, false)
    TriggerServerEvent('annuario:server:closeBook')
    cb('ok')
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        SetNuiFocus(false, false)
        SendNUIMessage({
            show = false
        })
        ClearPedSecondaryTask(PlayerPedId())
        if bookProp then
            SetEntityAsMissionEntity(bookProp)
            DeleteObject(bookProp)
        end
    end
end)

-- Handle ESC key to close book
RegisterNUICallback('close', function(data, cb)
    TriggerEvent('annuario:client:closeBook')
    cb('ok')
end)

-- Handle keyup events for ESC
RegisterNUICallback('keyup', function(data, cb)
    if (data.key == 27) then
        TriggerEvent('annuario:client:closeBook')
    end
    cb('ok')
end)

-- Debug command
RegisterCommand('booktest', function()
    print('[annuario] Trying to open book...')
    TriggerServerEvent('annuario:server:openBook')
end, false)

print('[annuario] Client book system loaded')