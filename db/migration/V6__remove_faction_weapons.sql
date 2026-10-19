-- ============================================================
-- Mordheim Builder - Retrait des armes spécifiques à des factions
-- (Sœurs de Sigmar, Skavens, ...). Elles seront réintroduites
-- avec la gestion des bandes/factions.
-- Flyway migration V6
-- ============================================================

DELETE FROM weapon
WHERE weapon_id IN (
    'b0000000-0000-0000-0000-000000000013', -- Fouet d'acier
    'b0000000-0000-0000-0000-000000000014', -- Marteau de guerre Sigmarite
    'b0000000-0000-0000-0000-000000000015', -- Lame Suintantes
    'b0000000-0000-0000-0000-000000000016', -- Griffes de Combat
    'b0000000-0000-0000-0000-000000000034', -- Sarbacane
    'b0000000-0000-0000-0000-000000000035'  -- Pistolet à Malepierre
);
