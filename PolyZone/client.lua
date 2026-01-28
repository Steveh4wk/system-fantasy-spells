local PolyZone = {}
local zones = {}
local playerInZone = {}

-- Create a polyzone
function PolyZone.Create(name, points, height, debug)
    local zone = {
        name = name,
        points = points,
        height = height or 10.0,
        debug = debug or false,
        playersInside = {}
    }
    
    zones[name] = zone
    
    if Config.DebugMode then
        PolyZone.DrawZone(zone)
    end
    
    return zone
end

-- Check if player is inside zone
function PolyZone.IsPlayerInZone(playerId, zoneName)
    local zone = zones[zoneName]
    if not zone then return false end
    
    local ped = GetPlayerPed(playerId)
    if not DoesEntityExist(ped) then return false end
    
    local coords = GetEntityCoords(ped)
    
    return PolyZone.IsPointInPolygon(coords, zone.points, zone.height)
end

-- Check if point is inside polygon
function PolyZone.IsPointInPolygon(point, polygon, height)
    local x, y, z = point.x, point.y, point.z
    
    -- Check height
    if z < polygon[1].z - height or z > polygon[1].z + height then
        return false
    end
    
    -- Ray casting algorithm for point in polygon
    local inside = false
    local j = #polygon
    
    for i = 1, #polygon do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y
        
        local condition1 = (yi > y) ~= (yj > y)
        local condition2 = x < (xj - xi) * (y - yi) / (yj - yi) + xi
        
        if condition1 and condition2 then
            inside = not inside
        end
        
        j = i
    end
    
    return inside
end

-- Draw zone for debugging
function PolyZone.DrawZone(zone)
    if not zone.debug then return end
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            
            -- Draw polygon outline
            for i = 1, #zone.points do
                local nextIndex = (i % #zone.points) + 1
                local point1 = zone.points[i]
                local point2 = zone.points[nextIndex]
                
                DrawLine(point1.x, point1.y, point1.z, point2.x, point2.y, point2.z, 255, 0, 0, 255)
            end
            
            -- Draw vertical lines to show height
            for i = 1, #zone.points do
                local point = zone.points[i]
                local bottom = vec3(point.x, point.y, point.z - zone.height)
                local top = vec3(point.x, point.y, point.z + zone.height)
                
                DrawLine(bottom.x, bottom.y, bottom.z, top.x, top.y, top.z, 0, 255, 255, 255)
            end
        end
    end)
end

-- Get all zones player is in
function PolyZone.GetPlayerZones(playerId)
    local playerZones = {}
    
    for zoneName, _ in pairs(zones) do
        if PolyZone.IsPlayerInZone(playerId, zoneName) then
            table.insert(playerZones, zoneName)
        end
    end
    
    return playerZones
end

-- Initialize zones from config
Citizen.CreateThread(function()
    for _, zoneData in ipairs(Config.Zones) do
        PolyZone.Create(zoneData.name, zoneData.points, zoneData.height, zoneData.debug)
    end
end)

-- Exports
exports('IsPlayerInZone', PolyZone.IsPlayerInZone)
exports('GetPlayerZones', PolyZone.GetPlayerZones)
exports('Create', PolyZone.Create)
