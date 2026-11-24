-- ============================================================
-- Mordheim Builder - Peuplement du catalogue de règles spéciales
-- Flyway migration V3
-- ============================================================

INSERT INTO special_rule (special_rule_id, name, description) VALUES
('a0000000-0000-0000-0000-000000000001', '+1 Sauvegarde ennemie', '+1 à la sauvegarde d''armure pour la cible de l''attaque'),
('a0000000-0000-0000-0000-000000000002', 'Contondant', 'Un jet de 2-4 est traité comme le résultat sonné'),
('a0000000-0000-0000-0000-000000000003', 'Modificateur de sauvegarde de -1', 'Modificateur de sauvegarde de -1 à la sauvegarde adverse'),
('a0000000-0000-0000-0000-000000000004', 'Parade', 'Lorsque l''adversaire jette les dés pour toucher, lancez 1D6 ; si le résultat est supérieur à son meilleur jet, son attaque est annulée. Une figurine ne peut pas parer une attaque ayant le double ou plus de sa propre force'),
('a0000000-0000-0000-0000-000000000005', 'Fatigue', 'Le bonus de +2 en Force ne s''applique qu''au premier tour de chaque combat au corps à corps'),
('a0000000-0000-0000-0000-000000000006', 'Arme à deux mains', 'Interdiction d''utiliser un bouclier, une rondache ou une arme additionnelle. Le bouclier donne tout de même son bonus de +1 à la sauvegarde contre les tirs'),
('a0000000-0000-0000-0000-000000000007', 'Difficile à manier', 'L''utilisation de la rondache ou d''une deuxième arme n''est pas autorisée'),
('a0000000-0000-0000-0000-000000000008', 'Frappe en premier', 'Frappe en premier lors du premier tour de corps à corps'),
('a0000000-0000-0000-0000-000000000009', 'Difficile à manier lance', 'Impossibilité de porter une deuxième arme dans l''autre main. Le bouclier et la rondache sont autorisés'),
('a0000000-0000-0000-0000-000000000010', 'Bonus de cavalerie lance', 'Un cavalier gagne un bonus de +1 en Force lors du tour où il charge'),
('a0000000-0000-0000-0000-000000000011', 'Arme de cavalerie', 'Doit posséder un destrier pour utiliser cette arme'),
('a0000000-0000-0000-0000-000000000012', 'Bonus de cavalerie Lance de cavalerie', 'Un cavalier gagne un bonus de +2 en Force lors du tour où il charge'),
('a0000000-0000-0000-0000-000000000013', 'Frappe en dernier', 'Frappe toujours en dernier même en ayant chargé'),
('a0000000-0000-0000-0000-000000000014', 'Arme en gromril', 'Modificateur de sauvegarde additionnel de -1'),
('a0000000-0000-0000-0000-000000000015', 'Arme en ithilmar', 'Donne +1 en initiative'),
('a0000000-0000-0000-0000-000000000016', 'Mouvement ou tir', 'Impossibilité de bouger et tirer. Pivoter sur place et se lever sont autorisés'),
('a0000000-0000-0000-0000-000000000017', 'Double tir à demi portée', 'Peut tirer deux fois s''il ne se déplace pas. La portée maximale est réduite de moitié et chaque tir a un malus de -1 pour toucher'),
('a0000000-0000-0000-0000-000000000018', 'Arme de jet', 'Pas de pénalité pour la longue portée ou pour avoir bougé. Impossible de l''utiliser au corps à corps'),
('a0000000-0000-0000-0000-000000000019', 'Double tir', 'Peut tirer deux fois par tour avec une pénalité de -1 pour toucher sur chaque tir'),
('a0000000-0000-0000-0000-000000000020', 'Tir au corps à corps', 'Peut tirer lors du premier tour de corps à corps. Il est résolu en premier avant les attaques, avec un malus de -2, en utilisant la CT de la figurine. Cette attaque s''ajoute aux attaques de corps à corps'),
('a0000000-0000-0000-0000-000000000021', 'Rechargement', 'Un tour complet pour recharger. Peut tirer à chaque tour avec une paire de l''arme utilisée'),
('a0000000-0000-0000-0000-000000000022', 'Corps à corps', 'Peut être utilisé au corps à corps et au tir. Équipé d''un pistolet comme arme additionnelle, rajoute +1 attaque de Force 4 et un modificateur d''armure de -2 à la phase de corps à corps, et peut être parée'),
('a0000000-0000-0000-0000-000000000023', 'Précision', 'Tir ou attaque au corps à corps donne un bonus de +1 pour toucher'),
('a0000000-0000-0000-0000-000000000024', 'Modificateur de sauvegarde -2', 'Modificateur de -2 à la sauvegarde adverse'),
('a0000000-0000-0000-0000-000000000025', 'Décharge', 'Tracez une ligne de 16ps de long et de 1ps de large. Toutes les figurines se trouvant dans le couloir subissent une touche de Force 3 (sauf les figurines cachées ou hors de vue du tireur)'),
('a0000000-0000-0000-0000-000000000026', 'Tir unique', 'Utilisable une seule fois par partie'),
('a0000000-0000-0000-0000-000000000027', 'Choix de la cible', 'Permet de choisir n''importe quelle figurine, pas uniquement la plus proche');
