-- Stefano Luciano Corp
-- Inizializzazione sistema Fantasy Peds

CreateThread(function()
    Wait(2000) -- Aspetta che tutto sia caricato
    
    -- Salva stato originale del giocatore
    if CreatureSystem and CreatureSystem.SaveOriginalState then
        CreatureSystem.SaveOriginalState()
        print('[Fantasy Peds] Stato originale salvato correttamente')
    else
        print('[Fantasy Peds] Errore: CreatureSystem non disponibile')
    end
end)
