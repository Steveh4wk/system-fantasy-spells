# Orologio Stellare - Integrato in Runa_System

## Descrizione
L'Orologio Stellare è stato integrato completamente in Runa_System per centralizzare tutte le funzionalità magiche.

## Funzionalità
- **Revive automatico**: Si attiva quando il giocatore muore e possiede l'orologio nell'inventario
- **Uso manuale**: Può essere usato manualmente dall'inventario
- **Cooldown**: 30 minuti di cooldown dopo l'uso
- **Effetti visivi**: Fumo e particelle durante l'attivazione
- **Interfaccia**: Animazione stellare con suono

## Comandi
- Nessun comando necessario, si attiva automaticamente alla morte

## File aggiunti
- `client/stellareWatch.lua` - Logica client dell'orologio
- `server/stellareWatch.lua` - Logica server con gestione cooldown
- `stellare_web/` - File dell'interfaccia web
- `items.lua` - Aggiunto item `orologiostellare`

## Configurazione
L'item è già configurato in `items.lua`:
```lua
['orologiostellare'] = {
    label = 'Orologio Stellare',
    weight = 0.5,
    stack = true,
    close = true,
    description = 'Orologio magico che ti revive automaticamente quando muori. Cooldown di 30 minuti.'
}
```

## Note
- La risorsa `magic-detector-ste` può essere rimossa dal server
- L'export `orologiostellare:use` è disponibile per ox_inventory
- Il sistema è completamente integrato con QBCore e ox_inventory
