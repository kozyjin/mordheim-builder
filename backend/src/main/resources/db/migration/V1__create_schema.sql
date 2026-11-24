-- ============================================================
-- Mordheim Builder - Schéma initial
-- Flyway migration V1
-- ============================================================

-- Extension nécessaire pour gen_random_uuid()
-- (pgcrypto est recommandé sur PostgreSQL moderne, inclus par défaut
--  à partir de PG 13 via la fonction native gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Table: warband
-- ============================================================
CREATE TABLE warband (
    warband_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(100) NOT NULL
);

-- ============================================================
-- Table: warrior
-- ============================================================
CREATE TABLE warrior (
    warrior_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warband_id      UUID NOT NULL REFERENCES warband(warband_id) ON DELETE CASCADE,

    name            VARCHAR(100) NOT NULL,
    is_hero         BOOLEAN NOT NULL DEFAULT false,
    cost            INTEGER NOT NULL,

    -- Ligne de statistiques M/WS/BS/S/T/W/I/A/Ld
    movement        SMALLINT NOT NULL,
    weapon_skill    SMALLINT NOT NULL,
    ballistic_skill SMALLINT NOT NULL,
    strength        SMALLINT NOT NULL,
    toughness       SMALLINT NOT NULL,
    wound           SMALLINT NOT NULL,
    initiative      SMALLINT NOT NULL,
    attack          SMALLINT NOT NULL,
    leadership      SMALLINT NOT NULL,

    experience      SMALLINT NOT NULL DEFAULT 0,
    special_rule    TEXT,

    -- NULL pour un Hero (toujours seul), valeur >= 1 pour un Henchman (groupe)
    group_size      SMALLINT,

    CONSTRAINT chk_hero_group_size CHECK (
        (is_hero = true  AND group_size IS NULL)
        OR
        (is_hero = false AND group_size >= 1)
    )
);

-- Index sur la FK : requête la plus fréquente = lister les guerriers d'une bande
CREATE INDEX idx_warrior_warband_id ON warrior(warband_id);

-- ============================================================
-- Table: weapon
-- ============================================================
CREATE TABLE weapon (
    weapon_id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name                    VARCHAR(100) NOT NULL,
    strength                SMALLINT,
    range                   SMALLINT,
    cost                    INTEGER NOT NULL,
    special_rule            TEXT,
    is_shooting_weapon      BOOLEAN NOT NULL DEFAULT false,
    is_close_combat_weapon  BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT chk_weapon_has_type CHECK (
        is_shooting_weapon = true OR is_close_combat_weapon = true
    )
);

-- ============================================================
-- Table de jointure: warrior_weapon (relation "Equipped")
-- ============================================================
CREATE TABLE warrior_weapon (
    warrior_id UUID NOT NULL REFERENCES warrior(warrior_id) ON DELETE CASCADE,
    weapon_id  UUID NOT NULL REFERENCES weapon(weapon_id) ON DELETE RESTRICT,
    quantity   SMALLINT NOT NULL DEFAULT 1 CHECK (quantity >= 1),

    PRIMARY KEY (warrior_id, weapon_id)
);

-- Index sur la FK côté weapon pour les requêtes inverses
-- (ex: "quels guerriers portent cette arme ?")
CREATE INDEX idx_warrior_weapon_weapon_id ON warrior_weapon(weapon_id);
