-- ============================================================
-- Mordheim Builder - Peuplement du catalogue d'armes
-- Flyway migration V5
-- ============================================================

-- Armes de corps à corps
INSERT INTO weapon (weapon_id, name, strength, range, cost, rarity, is_shooting_weapon, is_close_combat_weapon) VALUES
('b0000000-0000-0000-0000-000000000001', 'Arme à deux mains', 'Utilisateur +2', 'Corps à corps', 15, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000002', 'Dague', 'Utilisateur', 'Corps à corps', 2, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000003', 'Epée', 'Utilisateur', 'Corps à corps', 10, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000004', 'Fléau', 'Utilisateur +2', 'Corps à corps', 15, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000005', 'Goudin', 'Utilisateur', 'Corps à corps', 5, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000006', 'Hache', 'Utilisateur', 'Corps à corps', 5, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000007', 'Hallebarde', 'Utilisateur +1', 'Corps à corps', 10, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000008', 'Lance', 'Utilisateur', 'Corps à corps', 10, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000009', 'Lance de cavalerie', 'Utilisateur +2', 'Corps à corps', 40, 'Rare 8', false, true),
('b0000000-0000-0000-0000-000000000010', 'Morgenstern', 'Utilisateur +1', 'Corps à corps', 15, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000011', 'Masse', 'Utilisateur', 'Corps à corps', 5, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000012', 'Marteau', 'Utilisateur', 'Corps à corps', 5, 'Commun', false, true),
('b0000000-0000-0000-0000-000000000013', 'Fouet d''acier', 'Utilisateur', 'Corps à corps', 10, 'Commun (uniquement pour les sœurs de sigmar)', false, true),
('b0000000-0000-0000-0000-000000000014', 'Marteau de guerre Sigmarite', 'Utilisateur +1', 'Corps à corps', 15, 'Commun (uniquement pour les sœurs de sigmar)', false, true),
('b0000000-0000-0000-0000-000000000015', 'Lame Suintantes', 'Utilisateur', 'Corps à corps', 50, 'Rare 9 (Skavens uniquement)', false, true),
('b0000000-0000-0000-0000-000000000016', 'Griffes de Combat', 'Utilisateur', 'Corps à corps', 35, 'Rare 7 (Skavens uniquement)', false, true);

-- Armes de tir
INSERT INTO weapon (weapon_id, name, strength, range, cost, rarity, is_shooting_weapon, is_close_combat_weapon) VALUES
('b0000000-0000-0000-0000-000000000017', 'Arbalète', '4', '30ps', 25, 'Commun', true, false),
('b0000000-0000-0000-0000-000000000018', 'Arbalète à répétition', '3', '24ps', 40, 'Rare 8', true, false),
('b0000000-0000-0000-0000-000000000019', 'Arbalète de poing', '4', '10ps', 35, 'Rare 9', true, false),
('b0000000-0000-0000-0000-000000000020', 'Arc', '3', '24ps', 10, 'Commun', true, false),
('b0000000-0000-0000-0000-000000000021', 'Arc court', '3', '16ps', 5, 'Commun', true, false),
('b0000000-0000-0000-0000-000000000022', 'Arc Elfique', '3', '36ps', 35, 'Rare 12', true, false),
('b0000000-0000-0000-0000-000000000023', 'Arc long', '3', '30ps', 15, 'Commun', true, false),
('b0000000-0000-0000-0000-000000000024', 'Arquebuse', '4', '24ps', 35, 'Rare 8', true, false),
('b0000000-0000-0000-0000-000000000025', 'Etoiles', 'Utilisateur', '6', 15, 'Rare 5', true, false),
('b0000000-0000-0000-0000-000000000026', 'Couteaux de jet', 'Utilisateur', '6', 15, 'Rare 5', true, false),
('b0000000-0000-0000-0000-000000000027', 'Fronde', '3', '10ps', 2, 'Commun', true, false),
('b0000000-0000-0000-0000-000000000028', 'Long fusil d''Hochaland', '4', '48ps', 200, 'Rare 11', true, false),
('b0000000-0000-0000-0000-000000000029', 'Pistolet de duel', '4', '10ps', 30, 'Rare 10', true, false),
('b0000000-0000-0000-0000-000000000030', 'Paire de Pistolet de duel', '4', '10ps', 60, 'Rare 10', true, false),
('b0000000-0000-0000-0000-000000000031', 'Pistolet', '4', '6ps', 15, 'Rare 8', true, false),
('b0000000-0000-0000-0000-000000000032', 'Paire de Pistolet', '4', '10ps', 30, 'Rare 8', true, false),
('b0000000-0000-0000-0000-000000000033', 'Tromblon', '3', 'Spéciale', 30, 'Rare 9', true, false),
('b0000000-0000-0000-0000-000000000034', 'Sarbacane', '1', '8ps', 25, 'Rare 7', true, false),
('b0000000-0000-0000-0000-000000000035', 'Pistolet à Malepierre', '5', '8ps', 35, 'Rare 11', true, false);
