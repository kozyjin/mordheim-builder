-- ============================================================
-- Mordheim Builder - Ajustement des colonnes weapon
-- strength/range passent en VARCHAR (données d'affichage uniquement,
-- pas interprétées par le moteur de règles)
-- Ajout de la colonne rarity
-- Flyway migration V4
-- ============================================================

ALTER TABLE weapon
    ALTER COLUMN strength TYPE VARCHAR(50) USING strength::VARCHAR;

ALTER TABLE weapon
    ALTER COLUMN range TYPE VARCHAR(50) USING range::VARCHAR;

ALTER TABLE weapon
    ADD COLUMN rarity VARCHAR(100);
