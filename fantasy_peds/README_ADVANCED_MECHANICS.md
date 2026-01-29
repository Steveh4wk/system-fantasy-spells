SISTEMA CREATURE FANTASY AVANZATO

Questo sistema aggiunge meccaniche nuove ai vampiri e licantropi del tuo server FiveM RP.

COSA FA QUESTO SISTEMA

Per i Vampiri:
- Fame di sangue che scende col tempo
- Se fame bassa: perdi forza e velocita
- Se fame zero: perdi vita lentamente
- Puoi nutrirti da NPC o giocatori (con permesso)
- Ogni nutrimento ha un tempo di attesa
- Luce del sole ti fa male
- Fuoco ti fa piu male
- Oggetti sacri possono farti male (se attivi)
- Ogni nutrimento aumenta il livello vampiro
- Livelli piu alti sbloccano nuove magie

Per i Licantropi:
- Di notte hai bonus, di giorno sei debole
- Durante luna piena hai bonus massimi
- Sistema di rabbia che aumenta combattendo
- Se rabbia alta: fai piu danno e vai piu veloce
- Se rabbia massima: perdi controllo temporaneamente
- Rigeneri vita solo di notte, piu veloce con luna piena
- Argento ti fa piu male
- Magie specifiche ti fanno male

COME INSTALLARE

1. Copia tutti i file nella cartella fantasy_peds
2. Esegui il file create_tables.sql nel tuo database
3. Riavvia il server

COME USARE

Il sistema parte automaticamente. I giocatori possono:
- Usare /creatures per il menu creature
- Usare /spells per il menu magie
- Le nuove meccaniche funzionano da sole

CONFIGURAZIONE

Nel file shared/advanced_config.lua puoi:
- Attivare o disattivare ogni meccanica
- Cambiare valori come velocita fame, danni, ecc.
- Aggiungere nuove debolezze

ESEMPI CODICE

Sistema Fame Vampiro (client):
```lua
-- Ogni minuto controlla fame
Citizen.CreateThread(function()
    while true do
        Wait(60000) -- 1 minuto
        if IsVampire() then
            local hunger = GetVampireHunger()
            hunger = hunger - 5 -- diminuisci fame
            SetVampireHunger(hunger)

            if hunger < 20 then
                -- debuff velocita
                SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
            end
        end
    end
end)
```

Sistema Rabbia Licantropo (client):
```lua
-- Quando prendi danno, aumenta rabbia
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        if victim == PlayerPedId() and IsLycan() then
            local rage = GetLycanRage()
            rage = math.min(rage + 10, 100)
            SetLycanRage(rage)
        end
    end
end)
```

BILANCIAMENTO

Per rendere tutto RP:
- Fame vampiro scende piano (ogni 5 minuti -1)
- Nutrimento da giocatori solo con permesso
- Rabbia licantropo aumenta solo combattendo
- Debolezze non uccidono subito, solo rendono vulnerabili
- Progressione lenta per evitare powergaming

PROBLEMI COMUNI

- Se crash: controlla che tutti i file siano copiati
- Se magie non funzionano: controlla config.lua
- Se stati non si salvano: controlla database

Questo sistema e' fatto per integrarsi con quello che hai gia', senza rompere niente.