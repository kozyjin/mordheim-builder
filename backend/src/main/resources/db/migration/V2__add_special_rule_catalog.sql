-- ============================================================
-- Mordheim Builder - Catalogue de règles spéciales
-- Flyway migration V2
-- ============================================================

-- ============================================================
-- Table: special_rule (catalogue, une règle définie une seule fois)
-- ============================================================
CREATE TABLE special_rule (
    special_rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT NOT NULL
);

-- ============================================================
-- Table de jointure: weapon_special_rule
-- ============================================================
CREATE TABLE weapon_special_rule (
    weapon_id       UUID NOT NULL REFERENCES weapon(weapon_id) ON DELETE CASCADE,
    special_rule_id UUID NOT NULL REFERENCES special_rule(special_rule_id) ON DELETE RESTRICT,

    PRIMARY KEY (weapon_id, special_rule_id)
);

CREATE INDEX idx_weapon_special_rule_rule_id ON weapon_special_rule(special_rule_id);

-- ============================================================
-- Suppression de l'ancienne colonne texte libre sur weapon,
-- remplacée par le catalogue ci-dessus
-- ============================================================
ALTER TABLE weapon DROP COLUMN special_rule;
