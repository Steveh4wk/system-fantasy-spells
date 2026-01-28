-- MySQL Connection Optimization Configuration
-- This file helps prevent connection timeouts and aborted connections

local mysqlConfig = {
    -- Connection pool settings
    pool = {
        min = 2,           -- Minimum connections in pool
        max = 10,          -- Maximum connections in pool
        idleTimeout = 30000, -- Close idle connections after 30 seconds
        acquireTimeout = 60000 -- Wait max 60 seconds for connection
    },
    
    -- Query timeout settings
    query = {
        timeout = 30000,   -- Query timeout in milliseconds
        retries = 3        -- Number of retry attempts on failure
    },
    
    -- Connection settings
    connection = {
        connectTimeout = 10000,  -- Initial connection timeout
        timeout = 60000,        -- Socket timeout
        reconnect = true,        -- Auto-reconnect on disconnect
        keepAlive = true,       -- Enable TCP keep-alive
        keepAliveInitialDelay = 0
    }
}

-- Apply configuration to oxmysql
if GetResourceState('oxmysql') == 'started' then
    -- Configuration is applied via connection string parameters
    -- This file serves as documentation and future extension point
end

return mysqlConfig
