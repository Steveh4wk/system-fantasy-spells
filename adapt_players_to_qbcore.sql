-- Adatta la tabella players esistente per renderla compatibile con QBCore
-- Esegui questo script nel tuo database MySQL

-- Aggiungi le colonne necessarie per QBCore (se non esistono già)
ALTER TABLE players ADD COLUMN IF NOT EXISTS license VARCHAR(50) NULL;
ALTER TABLE players ADD COLUMN IF NOT EXISTS license2 VARCHAR(50) NULL;
ALTER TABLE players ADD COLUMN IF NOT EXISTS last_logged_out TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE players ADD COLUMN IF NOT EXISTS metadata LONGTEXT NULL DEFAULT NULL;
ALTER TABLE players ADD COLUMN IF NOT EXISTS position LONGTEXT NULL DEFAULT NULL;

-- Aggiungi gli indici necessari per QBCore
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_license (license);
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_license2 (license2);
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_citizenid (citizenid);

-- ... (rest del file aggiornato come l'originale)