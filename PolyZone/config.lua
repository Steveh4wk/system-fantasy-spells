-- PolyZone System Configuration
Config = {}

-- Zone definitions
Config.Zones = {
    -- Example zones - modify these for your server
    {
        name = "central_park",
        points = {
            vec3(150.0, -1000.0, 29.0),
            vec3(200.0, -1000.0, 29.0), 
            vec3(200.0, -900.0, 29.0),
            vec3(150.0, -900.0, 29.0)
        },
        height = 10.0,
        debug = true
    },
    {
        name = "hospital_zone",
        points = {
            vec3(300.0, -600.0, 30.0),
            vec3(400.0, -600.0, 30.0),
            vec3(400.0, -500.0, 30.0), 
            vec3(300.0, -500.0, 30.0)
        },
        height = 15.0,
        debug = true
    }
}

-- Zone settings
Config.DebugMode = true
Config.NotificationDistance = 5.0
