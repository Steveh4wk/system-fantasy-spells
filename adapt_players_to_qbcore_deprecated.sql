-- DEPRECATED: use adapt_players_to_qbcore.sql instead (previously renamed)
-- This script was renamed to `adapt_players_to_qbcore.sql`. Please use the new file instead.

-- Aggiungi gli indici necessari per QBCore
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_license (license);
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_license2 (license2);
ALTER TABLE players ADD INDEX IF NOT EXISTS idx_citizenid (citizenid);

-- Copia i dati esistenti nelle nuove colonne
-- Copia l'identifier nella colonna license (se license è vuota)
UPDATE players SET license = identifier WHERE license IS NULL AND identifier IS NOT NULL;

-- Copia l'identifier nella colonna license2 (se license2 è vuota)
UPDATE players SET license2 = identifier WHERE license2 IS NULL AND identifier IS NOT NULL;

-- Copia last_seen in last_logged_out (se last_logged_out è vuota)
UPDATE players SET last_logged_out = last_seen WHERE last_logged_out IS NULL AND last_seen IS NOT NULL;

-- Copia charinfo in metadata (se metadata è vuota)
UPDATE players SET metadata = charinfo WHERE metadata IS NULL AND charinfo IS NOT NULL;

-- Copia position (se position è vuota)
UPDATE players SET position = position WHERE position IS NULL AND position IS NOT NULL;

-- Aggiorna i valori di last_logged_out per i personaggi esistenti (se mancanti)
UPDATE players SET last_logged_out = NOW() WHERE last_logged_out IS NULL;

-- Aggiorna i valori di position per i personaggi esistenti (se mancanti)
UPDATE players SET position = '{"x":0,"y":0,"z":75,"w":0}' WHERE position IS NULL;

-- Aggiorna i valori di metadata per i personaggi esistenti (se mancanti)
UPDATE players SET metadata = '{"hunger":100,"thirst":100,"stress":0,"isdead":false,"inlaststand":false,"armor":0,"ishandcuffed":false,"tracker":false,"injail":false,"jailitems":[],"status":[],"phone":"0000000000","fitbit":"0000000000","callsign":"000","fingerprint":"000000000000","walletid":"000000000000","criminalrecord":{"hasRecord":false,"date":null},"driverlicense":{"hasLicense":false,"date":null},"weaponlicense":{"hasLicense":false,"date":null},"houselocation":null}' WHERE metadata IS NULL;

-- Crea la tabella player_groups se non esiste (per i gruppi lavoro/gang)
CREATE TABLE IF NOT EXISTS player_groups (
    citizenid VARCHAR(50) NOT NULL,
    type ENUM('job','gang') NOT NULL,
    `group` VARCHAR(50) NOT NULL,
    grade INT NOT NULL,
    PRIMARY KEY (citizenid, type, `group`),
    FOREIGN KEY (citizenid) REFERENCES players(citizenid) ON DELETE CASCADE
);

-- Crea la tabella playerskins se non esiste (per l'aspetto dei personaggi)
CREATE TABLE IF NOT EXISTS playerskins (
    citizenid VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    skin LONGTEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (citizenid, model),
    FOREIGN KEY (citizenid) REFERENCES players(citizenid) ON DELETE CASCADE
);

-- Crea la tabella bans se non esiste (per i ban)
CREATE TABLE IF NOT EXISTS bans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    license VARCHAR(50),
    discord VARCHAR(50),
    ip VARCHAR(50),
    reason TEXT NOT NULL,
    expire TIMESTAMP NULL,
    bannedby VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_license (license),
    INDEX idx_discord (discord),
    INDEX idx_ip (ip)
);

-- Aggiorna eventuali valori nulli in colonne importanti
UPDATE players SET position = '{"x":0,"y":0,"z":75,"w":0}' WHERE position IS NULL;
UPDATE players SET metadata = '{}' WHERE metadata IS NULL;

-- Verifica la struttura finale della tabella players
DESCRIBE players;