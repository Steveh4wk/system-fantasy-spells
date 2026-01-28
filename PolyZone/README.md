# PolyZone System

## Come Funziona

Il sistema PolyZone permette di creare aree poligonali (zone) sulla mappa e rilevare quando i giocatori entrano o escono da queste aree.

## File Creati

1. **fxmanifest.lua** - Manifest file del resource
2. **config.lua** - Configurazione delle zone
3. **client.lua** - Logica client-side per il rilevamento
4. **server.lua** - Logica server-side per la gestione eventi

## Come Collegare alla Mappa

### 1. Configurare le Zone

Modifica il file `config.lua` per definire le tue zone:

```lua
Config.Zones = {
    {
        name = "nome_zona",
        points = {
            vec3(x1, y1, z1),
            vec3(x2, y2, z2),
            vec3(x3, y3, z3),
            vec3(x4, y4, z4)
        },
        height = 10.0,  -- Altezza della zona
        debug = true    -- Mostra i bordi della zona
    }
}
```

### 2. Ottenere Coordinate

Per ottenere le coordinate:
1. Vai nella posizione desiderata nel gioco
2. Usa il comando `coords` (se disponibile) o guarda la console F8
3. Prendi nota delle coordinate X, Y, Z

### 3. Attivare Debug Mode

Imposta `Config.DebugMode = true` in `config.lua` per vedere:
- Bordi delle zone (linee rosse)
- Linee verticali di altezza (linee gialle)

## Funzioni Disponibili

### Client-side
```lua
-- Controlla se giocatore è in una zona
local inZone = exports['PolyZone']:IsPlayerInZone(PlayerId(), 'nome_zona')

-- Ottieni tutte le zone del giocatore
local zones = exports['PolyZone']:GetPlayerZones(PlayerId())

-- Crea una nuova zona
exports['PolyZone']:Create('nuova_zona', points, height, debug)
```

### Server-side
```lua
-- Controlla se giocatore è in una zona
local inZone = exports['PolyZone']:IsPlayerInZone(source, 'nome_zona')
```

## Eventi Disponibili

### Client Events
- `polyzone:client:playerEnteredZone` - Quando un giocatore entra in una zona
- `polyzone:client:playerLeftZone` - Quando un giocatore esce da una zona

### Server Events  
- `polyzone:server:playerEnteredZone` - Quando un giocatore entra in una zona
- `polyzone:server:playerLeftZone` - Quando un giocatore esce da una zona

## Esempio di Utilizzo

```lua
-- In un altro resource
AddEventHandler('playerSpawned', function()
    Citizen.Wait(1000)
    
    -- Controlla se il giocatore è spawnato in una zona specifica
    if exports['PolyZone']:IsPlayerInZone(PlayerId(), 'hospital_zone') then
        TriggerEvent('chat:addMessage', {
            args = { '^2INFO', 'Sei nell\\'area dell\\'ospedale!' }
        })
    end
end)
```

## Avviare il Resource

1. Assicurati che `oxmysql` sia installato
2. Riavvia il server o usa `refresh`
3. Avvia il resource con `start PolyZone`

## Note Importanti

- Le zone sono poligoni 2D con altezza
- Il sistema usa ray-casting per il rilevamento preciso
- Il debug mode è utile per il testing e il setup iniziale
