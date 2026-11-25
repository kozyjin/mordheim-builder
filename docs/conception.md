# Mordheim Builder : document de conception

> Ce document récapitule les décisions prises, **et surtout leurs raisons**. Il sert de support pour expliquer le projet en entretien. Chaque choix est présenté avec ses alternatives et ses compromis.

Légende de statut utilisée dans le document :
- **Décidé et réalisé** : présent dans le dépôt.
- **Décidé, à implémenter** : choix arrêté, code pas encore écrit.
- **Piste envisagée** : idée discutée, non tranchée.

---

## 1. Contexte et objectifs

**Objectif du projet** : un utilitaire web gratuit de création de liste d'armée pour des jeux Games Workshop considérés comme abandonnés, en commençant par **Mordheim**.

**Objectif personnel** : monter en compétences sur un cas concret, avec une architecture soignée, pour étayer des candidatures. Le projet est donc volontairement construit comme un vrai produit (migrations versionnées, séparation domaine/infrastructure, tests ciblés) plutôt que comme un simple CRUD.

**Périmètre du POC** : récupérer une bande (avec ses guerriers et leur équipement) de bout en bout : base de données, API, interface. Accès **anonyme**, sans compte, sans enregistrement. Les fonctionnalités sont ajoutées **par lots**.

### Pourquoi Mordheim ?
- Jeu sans nouvelle édition ni support officiel actif, contrairement à d'autres jeux GW relancés récemment.
- Communauté encore active, outils existants souvent vieillissants.
- Règles riches : progression de personnage, contraintes de composition de bande, équipement avec règles d'exclusion, règles spéciales. C'est un vrai **moteur de règles** à concevoir, pas juste un additionneur de points.

### Propriété intellectuelle
« Abandonné » ne signifie pas « libre de droits ». Précautions retenues :
- projet **gratuit et non monétisé**, présenté comme **non officiel et non affilié** à Games Workshop ;
- aucun logo, illustration ou asset officiel ;
- éviter les marques dans le nom du projet ;
- données de règles saisies par l'auteur à partir de ses propres notes (zone grise reconnue) ;
- séparer le **moteur de règles** du **contenu de règles** (le contenu est dans des migrations de seed, donc facile à retirer ou réécrire).

---

## 2. Stack technique

| Couche | Choix | Statut |
|---|---|---|
| Base de données | PostgreSQL, modèle **full relationnel** | Réalisé |
| Migrations | **Flyway** (scripts SQL versionnés) | Réalisé |
| Environnement local | Docker Compose (PostgreSQL 16) | Réalisé |
| Backend | Java 17, Spring Boot 4, Maven, JPA, **architecture hexagonale stricte** | En cours : domaine et premier cas d'usage réalisés |
| Frontend | Angular 20, **Signals**, composants standalone, **NgRx** (pour la formation) | À implémenter |

### Spring Boot 4 : starters modulaires
Depuis Spring Boot 4, les auto-configurations sont modularisées : un simple `flyway-core` ne suffit plus à déclencher Flyway au démarrage, il faut le starter `spring-boot-starter-flyway`. De même `spring-boot-starter-web` devient `spring-boot-starter-webmvc`, et chaque starter a son pendant `-test`. Le projet utilise `webmvc`, `data-jpa`, `flyway`, `validation`, plus `flyway-database-postgresql` et le driver PostgreSQL en scope `runtime`.

### Configuration de l'application
La configuration est **externalisée** dans `application.yml` : l'URL de la base, les identifiants et les options JPA ne sont pas dans le code, donc pas de recompilation par environnement. YAML est préféré à `.properties` pour sa structure hiérarchique (l'indentation est significative, espaces uniquement).

- `${DB_USER:mordheim}` lit la variable d'environnement `DB_USER`, avec une valeur par défaut pour le développement local. Les variables d'environnement **surchargent** le fichier, ce qui permet de ne mettre aucun secret dans le dépôt en production.
- `ddl-auto: validate` : Hibernate vérifie le schéma sans jamais le modifier, Flyway reste seul maître du schéma.
- `open-in-view: false` : désactive la session JPA ouverte jusqu'au rendu de la réponse HTTP, qui masque les problèmes de lazy loading et de requêtes N+1.

Un seul format de configuration est conservé dans le projet (`application.yml`).

### Pourquoi du relationnel pur ?
Le domaine est naturellement relationnel (bande → guerriers → équipement → règles). Clés étrangères et intégrité référentielle collent bien. JSONB reste possible pour des cas atypiques, mais **en exception, pas en réflexe** (voir §4.3).

---

## 3. Architecture hexagonale

**Statut : décidé. Domaine et premier cas d'usage (lecture des armes) réalisés ; adaptateurs de persistance et web à venir.**

### Le principe
Le **domaine** (règles du jeu) ne dépend de rien : ni Spring, ni JPA, ni HTTP. Il définit des **ports** (interfaces). L'infrastructure fournit des **adaptateurs** qui implémentent ces ports.

### La tension à connaître
JPA pousse vers des entités annotées, orientées persistance (lazy loading, cascades), alors que l'hexagonal veut un domaine pur. Deux options ont été comparées :

1. **Hexagonal strict** : modèle de domaine en Java pur, entités JPA **séparées** dans l'adaptateur de persistance, avec des **mappers** entre les deux. Plus de code, mais domaine testable en JUnit pur, sans contexte Spring.
2. **Hexagonal pragmatique** : les entités JPA servent aussi de modèle de domaine. Plus rapide, moins pur.

**Choix : option 1 (strict)**, parce que le but est de démontrer la maîtrise de la séparation domaine/infrastructure.

### Découpage de packages
```
com.mordheimbuilder
├── MordheimBuilderApplication.java   (à la racine : Spring scanne ses sous-packages)
├── domain
│   ├── model            Warband, Warrior, Weapon, SpecialRule... (records / POJO purs)
│   ├── port
│   │   └── out          WeaponRepository (ce dont le domaine a besoin)
│   └── service          règles métier pures
├── application
│   ├── port
│   │   └── in           ListWeaponsUseCase (ce que l'application offre)
│   └── usecase          ListWeaponsService (implémentation du cas d'usage)
└── infrastructure
    ├── persistence      entités JPA, repository Spring Data, mapper, adaptateur
    ├── web              contrôleurs REST + DTO
    └── config           câblage des beans
```

### Règle d'or
La logique de règles vit dans `domain/service`, **jamais** dans les entités JPA ni dans les contrôleurs. C'est là que se trouve la valeur démonstrative du projet.

### Règle de dépendance
Les dépendances vont toujours **vers l'intérieur**. C'est elle qui fait l'architecture hexagonale, bien plus que les noms de dossiers.

| Couche | A le droit de dépendre de | Ne doit jamais dépendre de |
|---|---|---|
| `domain` | rien (Java standard seulement) | `application`, `infrastructure`, Spring, JPA, Jackson |
| `application` | `domain` | `infrastructure`, Spring |
| `infrastructure` | `application` et `domain` | rien d'interdit |

Un import `org.springframework...` ou `jakarta.persistence...` dans `domain` ou `application` signale une violation. À terme, un test **ArchUnit** pourra le vérifier automatiquement.

### Ports et adaptateurs
- **Port d'entrée** (`application/port/in`) : ce que l'application *offre* (`ListWeaponsUseCase`). Il est **appelé** par un adaptateur d'entrée (le contrôleur REST) et **implémenté** par le service de cas d'usage.
- **Port de sortie** (`domain/port/out`) : ce dont le domaine *a besoin* (`WeaponRepository`). Il est **appelé** par le service et **implémenté** par un adaptateur de sortie (l'adaptateur JPA).
- Le service n'« appelle pas le domaine » : il **orchestre**, en obtenant des objets du domaine par le port de sortie et en appliquant les règles.

**Inversion de dépendances** : l'interface `WeaponRepository` appartient au domaine (couche intérieure), son implémentation est à l'extérieur. L'infrastructure dépend du domaine, jamais l'inverse. On peut donc remplacer JPA sans toucher au service, et tester le service avec un faux repository.

### Spring dans la couche application
Deux écoles : annoter les services avec `@Service` (pragmatique, mais la couche `application` dépend alors de Spring), ou garder les services en **Java pur** et les déclarer comme beans dans une classe `@Configuration` de `infrastructure/config` (strict). **Choix : strict.** `ListWeaponsService` n'a aucune annotation et reçoit ses dépendances par le constructeur.

### Trois représentations d'une arme
| Représentation | Rôle | Annotée par |
|---|---|---|
| `Weapon` (domaine) | règles métier | rien |
| `WeaponEntity` (JPA) | lecture et écriture en base | JPA |
| `WeaponResponse` (DTO) | contrat de l'API JSON | éventuellement Jackson |

Les entités JPA sont de vraies **classes** (JPA exige des classes non finales avec un constructeur sans argument, Hibernate ne supporte pas les `record` comme entités). C'est l'une des raisons concrètes de la séparation. Un changement de colonne ne doit pas casser le contrat de l'API, et le domaine ne doit pas être pollué par les annotations. Un **mapper** convertit entre entité et domaine.

### Modèle de domaine réalisé
`Weapon` et `SpecialRule` sont des `record` Java sans aucune annotation. Leur **constructeur compact** protège les invariants :
- `id` et `name` obligatoires, `name` non vide ;
- `cost >= 0` ;
- une arme est de tir, de corps à corps, ou **les deux**, jamais aucun des deux (même règle que `chk_weapon_has_type` en base) ;
- la liste de règles spéciales est copiée (`List.copyOf`), donc non modifiable et protégée des modifications extérieures ;
- `strength`, `range` et `rarity` restent facultatifs, comme en base (données d'affichage).

La règle existe donc à **deux endroits** : la base en dernier rempart, le domaine pour échouer tôt avec un message clair, sans base de données.

### Premier cas d'usage réalisé : lister les armes
`ListWeaponsUseCase.listWeapons()` (port d'entrée) est implémenté par `ListWeaponsService`, qui délègue à `WeaponRepository.findAll()` (port de sortie). Contrat du port : `findAll()` ne renvoie jamais `null` (liste vide s'il n'y a aucune arme), l'adaptateur JPA devra le respecter. Le service ne contient aucune règle métier pour l'instant : la valeur est dans la structure et dans sa testabilité.

### Frontend
- **Signals** et composants standalone (plus de NgModules).
- **NgRx** introduit volontairement pour la formation, même si de simples services à signals suffiraient pour cette taille de projet. C'est un choix assumé et à expliquer comme tel.

### Pistes envisagées (non tranchées)
- Générer le client HTTP Angular depuis une spec **OpenAPI** produite par Spring (springdoc-openapi).
- **Testcontainers** pour tester les adaptateurs JPA contre un vrai PostgreSQL.

---

## 4. Modèle de données

**Statut : réalisé** (migrations V1 à V7).

### 4.1 Schéma

```mermaid
erDiagram
    WARBAND ||--o{ WARRIOR : "composed_of"
    WARRIOR ||--o{ WARRIOR_WEAPON : "equipped"
    WEAPON  ||--o{ WARRIOR_WEAPON : "equipped"
    WEAPON  ||--o{ WEAPON_SPECIAL_RULE : "has"
    SPECIAL_RULE ||--o{ WEAPON_SPECIAL_RULE : "applies_to"

    WARBAND {
        uuid warband_id PK
        varchar name
    }
    WARRIOR {
        uuid warrior_id PK
        uuid warband_id FK
        varchar name
        boolean is_hero
        int cost
        smallint movement
        smallint weapon_skill
        smallint ballistic_skill
        smallint strength
        smallint toughness
        smallint wound
        smallint initiative
        smallint attack
        smallint leadership
        smallint experience
        text special_rule
        smallint group_size "NULL pour un héros"
    }
    WEAPON {
        uuid weapon_id PK
        varchar name
        varchar strength "affichage"
        varchar range "affichage"
        int cost
        varchar rarity "affichage"
        boolean is_shooting_weapon
        boolean is_close_combat_weapon
    }
    SPECIAL_RULE {
        uuid special_rule_id PK
        varchar name UK
        text description
    }
    WARRIOR_WEAPON {
        uuid warrior_id PK,FK
        uuid weapon_id PK,FK
        smallint quantity
    }
    WEAPON_SPECIAL_RULE {
        uuid weapon_id PK,FK
        uuid special_rule_id PK,FK
    }
```

### 4.2 Lecture du modèle
- **Warband (0,N) — Composed_of — (1,1) Warrior** : un guerrier appartient à exactement une bande. Traduit par `warrior.warband_id NOT NULL`, sans table de jointure (relation 1-N classique).
- **Warrior (0,N) — Equipped — (0,N) Weapon** : many-to-many, matérialisé par `warrior_weapon`.
- **Weapon (0,N) — (0,N) SpecialRule** : many-to-many, matérialisé par `weapon_special_rule`. Une arme porte souvent **plusieurs** règles.
- La ligne de statistiques du guerrier suit l'ordre Mordheim : M / WS / BS / S / T / W / I / A / Ld.

### 4.3 Décisions de modélisation et justifications

| Décision | Raison | Alternative écartée |
|---|---|---|
| **Clés primaires en UUID** | Accès anonyme : un identifiant non séquentiel dans l'URL évite l'énumération (`/warband/1`, `/warband/2`...). Changer le type de clé plus tard obligerait à refaire toutes les FK. | `BIGSERIAL` |
| **UUID explicites dans les seeds** | Scripts lisibles, stables d'un environnement à l'autre, associations sans sous-requêtes. | `gen_random_uuid()` avec recherche par nom |
| **`is_hero` booléen + `group_size` nullable** | Un héros est toujours seul (`group_size` NULL), un homme de main appartient à un groupe de taille ≥ 1. Contrainte `chk_hero_group_size` en base. | Enum de type, colonne toujours renseignée |
| **`quantity` sur `warrior_weapon`** | Un guerrier peut porter plusieurs exemplaires d'une même arme. Clé composite `(warrior_id, weapon_id)` + quantité, au lieu de dupliquer des lignes. | Clé technique + lignes dupliquées |
| **Contrainte `chk_weapon_has_type`** | Une arme est au moins de tir **ou** de corps à corps. Deux booléens (et non un enum) pour pouvoir représenter les deux à la fois. | Enum exclusif |
| **Catalogue `special_rule` + table de jointure** | Une règle est définie **une seule fois** et réutilisée. Résout le many-to-many (une arme a plusieurs règles). | Colonne texte sur `weapon` |
| **`strength`, `range`, `rarity` en VARCHAR** | Valeurs purement d'affichage sur la feuille d'armée, souvent non numériques (« Utilisateur +2 », « Spéciale », « Rare 8 »). | `SMALLINT` |
| **Pas de JSONB pour l'instant** | Pas de besoin d'interprétation automatique des effets. JSONB serait de la complexité gratuite. | JSONB sur `special_rule` |
| **`weapon` limitée aux armes** | Armures et équipements divers auront leurs propres tables, pour ne pas brouiller la sémantique. | Table « equipment » générique |
| **Stats en `SMALLINT`, coûts en `INTEGER`** | Valeurs petites, coûts en couronnes d'or entières. `special_rule` et descriptions en `TEXT`. | `INTEGER` partout |

**Compromis à assumer sur les VARCHAR** : on perd le tri et le filtrage numériques en SQL sur ces colonnes. C'est acceptable parce qu'elles ne servent qu'à l'affichage. Si le moteur doit un jour les interpréter, il faudra les restructurer.

### 4.4 Intégrité référentielle (comportement à la suppression)

| Relation | Politique | Pourquoi |
|---|---|---|
| `warrior.warband_id` → `warband` | `ON DELETE CASCADE` | Supprimer une bande supprime ses guerriers (même agrégat). |
| `warrior_weapon.warrior_id` → `warrior` | `CASCADE` | Un guerrier supprimé n'a plus d'équipement. |
| `warrior_weapon.weapon_id` → `weapon` | `RESTRICT` | On ne supprime pas du catalogue une arme encore portée. |
| `weapon_special_rule.weapon_id` → `weapon` | `CASCADE` | Les associations suivent l'arme. |
| `weapon_special_rule.special_rule_id` → `special_rule` | `RESTRICT` | On ne supprime pas une règle encore utilisée. |

### 4.5 Index
- PostgreSQL indexe automatiquement les **clés primaires**, **pas** les clés étrangères.
- `idx_warrior_warband_id` : la requête la plus fréquente est « tous les guerriers d'une bande » (`WHERE warband_id = ?`). Sans index, PostgreSQL parcourt toute la table (*sequential scan*).
- `idx_warrior_weapon_weapon_id` et `idx_weapon_special_rule_rule_id` : requêtes inverses (« qui porte cette arme ? », « quelles armes ont cette règle ? »). Les clés composites couvrent déjà le sens direct.
- Index **B-tree** par défaut. Vérification avec `EXPLAIN ANALYZE` (on cherche un `Index Scan`).
- Garder en tête : chaque index ralentit les écritures, il ne faut donc pas sur-indexer.

### 4.6 Récupérer les règles d'une arme
Jointure classique via la table pivot. Pour une API, on agrège en une ligne par arme :
```sql
SELECT w.weapon_id, w.name,
       COALESCE(JSON_AGG(JSON_BUILD_OBJECT(
           'id', sr.special_rule_id, 'name', sr.name, 'description', sr.description))
         FILTER (WHERE sr.special_rule_id IS NOT NULL), '[]') AS special_rules
FROM weapon w
LEFT JOIN weapon_special_rule wsr ON wsr.weapon_id = w.weapon_id
LEFT JOIN special_rule sr ON sr.special_rule_id = wsr.special_rule_id
GROUP BY w.weapon_id, w.name;
```
`LEFT JOIN` pour conserver les armes sans règle ; `FILTER` et `COALESCE` pour éviter un `[null]`.

---

## 5. Migrations Flyway

### Principe
Flyway versionne le schéma comme Git versionne le code. Il tient une table `flyway_schema_history` (version, checksum de chaque script appliqué).

- Nommage : `V{version}__{description}.sql` (double underscore).
- **Immutabilité** : une migration appliquée ne se modifie jamais (le checksum ne correspondrait plus et Flyway refuse de démarrer). Toute correction passe par une **nouvelle** migration.
- Avec Spring Boot : `spring.jpa.hibernate.ddl-auto=validate`. Hibernate **vérifie** le schéma sans jamais le modifier ; seul Flyway le fait évoluer. Un seul système de vérité.

### Historique

| Version | Contenu |
|---|---|
| `V1__create_schema` | Tables `warband`, `warrior`, `weapon`, `warrior_weapon`, contraintes, index, extension `pgcrypto` |
| `V2__add_special_rule_catalog` | Catalogue `special_rule`, table `weapon_special_rule`, suppression de l'ancienne colonne texte sur `weapon` |
| `V3__seed_special_rules` | 27 règles spéciales |
| `V4__alter_weapon_columns` | `strength` et `range` en VARCHAR, ajout de `rarity` |
| `V5__seed_weapons` | 35 armes (corps à corps et tir) |
| `V6__remove_faction_weapons` | Retrait de 6 armes liées à des factions (réintroduites avec les bandes) |
| `V7__seed_weapon_special_rules` | 46 associations arme ↔ règle |

**Point à raconter** : V6 et V4 sont des migrations **correctives** plutôt que des retouches de V1/V5, précisément à cause de la règle d'immutabilité.

### État de la base après V7
- 27 règles spéciales
- 29 armes
- 46 associations arme ↔ règle
- aucune bande ni guerrier (données de démonstration à prévoir dans un fichier séparé, hors du dossier de migrations)

---

## 6. Règles métier : où vivent-elles ?

| Règle | Où | Statut |
|---|---|---|
| Pas deux armes à deux mains, etc. | **Validation côté Java** (domaine) à l'enregistrement **et** validation Angular qui conditionne le bouton d'enregistrement | À implémenter |
| Hero ↔ `group_size` | Contrainte `CHECK` en base (défense en profondeur) + domaine | Base : réalisé |
| Arme de tir ou de corps à corps | Contrainte `CHECK` en base + constructeur du record `Weapon` | Réalisé |
| Champs obligatoires, coût positif, liste de règles protégée | Constructeur compact des records du domaine | Réalisé |
| Première dague gratuite | Service de domaine au recrutement (pas un attribut de l'arme) | À implémenter |
| Coût de l'Arc elfique : base 35 + 3d6 | Calcul au moment de l'achat (la base ne stocke que 35) | À implémenter |
| Restrictions de faction | Reportées : armes de faction retirées pour l'instant | Différé |

### Le principe à défendre
Une règle posée **uniquement dans l'IHM** est un confort d'usage, pas une garantie d'intégrité : n'importe quel client de l'API (Postman, curl, un futur client mobile) pourrait créer une bande invalide. La règle doit donc exister côté domaine ; la validation front n'est qu'une aide à l'utilisateur. Pour un POC en **lecture seule**, ce n'est pas encore critique : le sujet devient réel avec la création/modification de bande.

---

## 7. Environnement local

```bash
docker compose up -d                          # démarre PostgreSQL 16
flyway -configFiles=flyway.conf migrate       # applique V1..V7
docker exec -it mordheim-postgres psql -U mordheim -d mordheim_builder
```

Vérifications utiles : `\dt` (tables), `\d weapon` (colonnes, contraintes, index), `SELECT * FROM flyway_schema_history;`.

Pour repartir de zéro en développement :
```bash
docker compose down -v && docker compose up -d && flyway -configFiles=flyway.conf migrate
```

**Backend** (depuis le dossier `backend/`, base démarrée) :
```bash
mvnw spring-boot:run     # démarre l'API (Flyway valide les migrations au démarrage)
mvnw clean test          # exécute tous les tests ; clean supprime les classes compilées périmées
```
Le test `MordheimBuilderApplicationTests` démarre toute l'application, il a donc besoin de la base : c'est un test d'intégration, d'une autre nature que les tests unitaires du domaine. Les noms de packages Java sont en **minuscules** (un renommage de casse sous Windows peut laisser des classes périmées dans `target/`).

Docker Desktop sous Windows nécessite la **virtualisation activée au BIOS** et WSL2. Les identifiants du `docker-compose.yml` et de `flyway.conf` sont des valeurs de **développement local** uniquement.

---

## 8. Stratégie de tests

| Niveau | Outil | Contenu | Statut |
|---|---|---|---|
| Domaine | JUnit 5 pur | invariants des records `Weapon` et `SpecialRule`, sans Spring ni base | Réalisé |
| Cas d'usage | JUnit 5 + Mockito | `ListWeaponsService` avec un `WeaponRepository` simulé | Réalisé |
| Adaptateur de persistance | Testcontainers + PostgreSQL | requêtes JPA contre une vraie base | À venir |
| Démarrage | `@SpringBootTest` | le contexte se charge, Flyway et la validation JPA passent | Réalisé |

**Conventions**
- Le test vit dans le **même package** que la classe testée, nommé `NomDeLaClasseTest`.
- Noms de test qui décrivent le comportement (`shouldRejectBlankName`), en anglais, avec un style unique.
- Structure **Arrange / Act / Assert** séparée par des lignes vides.
- Un test n'a qu'**une seule raison d'échouer** : tous les autres arguments sont valides.
- `assertEquals(expected, actual)` dans cet ordre.
- Pour vérifier qu'un test peut échouer, on casse volontairement le code et on regarde le test devenir rouge.
- `assertThrows(Type.class, () -> ...)` : la lambda retarde l'exécution du code, pour que l'exception soit captée par `assertThrows`.

**Mockito**
- On ne mocke **jamais la classe testée**, seulement ses dépendances.
- `verify` prouve qu'un appel a eu lieu, pas que le résultat est correct. Il est surtout utile pour les méthodes sans valeur de retour ou pour vérifier qu'un appel n'a pas eu lieu. En abuser couple le test à l'implémentation.
- Le mode strict de Mockito fait échouer le test si un `when(...)` n'est jamais utilisé : il détecte du code de test mort.
- Pour un repository à plusieurs opérations, un **fake** en mémoire écrit à la main peut être plus lisible que des `when` répétés. Mockito suffit pour un cas simple comme la lecture.
- Fiche détaillée : [`guide-mockito.md`](guide-mockito.md).

---

## 9. Limites connues et prochaines étapes

**Limites assumées du POC**
- Pas d'authentification, aucune notion de propriétaire de bande.
- `warrior.special_rule` reste du texte libre (le catalogue de règles ne sert pour l'instant qu'aux armes).
- Pas de notion de faction, de compétences, de blessures, d'armures ni d'équipement divers.
- Pas de jeu de données de démonstration (bandes, guerriers).
- Pas encore d'adaptateur de persistance ni d'API REST : le cas d'usage de lecture des armes n'est pas encore accessible de l'extérieur.

**Roadmap par lots (indicative)**
1. **Réalisé** : schéma PostgreSQL, migrations Flyway V1 à V7, données de catalogue (règles et armes).
2. **Réalisé** : projet Spring Boot, modèle de domaine (`Weapon`, `SpecialRule`), premier cas d'usage de lecture des armes avec ses tests.
3. **En cours** : persistance JPA (entités, repository Spring Data, mapper, adaptateur) testée avec Testcontainers.
4. Contrôleur REST et DTO pour `GET /api/weapons`, câblage des beans dans `infrastructure/config`.
5. Récupération d'une bande avec ses guerriers, jeu de données de démonstration.
6. Frontend Angular : affichage des armes puis d'une bande.
7. Création/modification de bande avec validations d'équipement côté domaine.
8. Factions, armures, équipements divers, compétences, progression.

---

## 10. Questions d'entretien probables

**Pourquoi une architecture hexagonale stricte sur un projet de cette taille ?**
Pour isoler la logique métier (règles du jeu) de Spring et de JPA : domaine testable en JUnit pur, persistance interchangeable. Je sais que c'est plus de code (mappers), c'est un compromis assumé pour démontrer la séparation, et je choisirais peut-être une version pragmatique sur un projet à faible enjeu métier.

**Quel est le problème entre hexagonal et JPA ?**
JPA incite à des entités annotées, couplées à la persistance (lazy loading, cascades). En hexagonal strict, j'ai un modèle de domaine pur et des entités JPA séparées dans l'adaptateur, reliées par des mappers.

**Pourquoi des UUID plutôt que des entiers auto-incrémentés ?**
Accès anonyme : l'identifiant est exposé dans l'URL, donc non devinable. Coût : index un peu plus gros et moins lisibles. Et surtout, changer le type de clé plus tard obligerait à refaire toutes les clés étrangères.

**Pourquoi Flyway plutôt que `ddl-auto=update` ?**
Schéma versionné, reproductible, relu en revue de code, identique sur tous les environnements. Avec `validate`, Hibernate contrôle sans modifier. Je respecte l'immutabilité des migrations : toute correction est une nouvelle migration.

**Pourquoi pas JSONB pour les règles spéciales ?**
Une arme a plusieurs règles : c'est un many-to-many classique, mieux servi par un catalogue et une table de jointure. JSONB n'apporterait rien tant que le moteur n'interprète pas les effets. Je l'envisagerais pour des paramètres variables d'effets si un moteur de combat automatique voyait le jour.

**Pourquoi `strength` et `range` en VARCHAR ?**
Ce sont des valeurs d'affichage, parfois non numériques (« Utilisateur +2 »). Je renonce au tri numérique en SQL, ce qui est acceptable tant que le moteur ne les calcule pas.

**Où se trouve la règle « pas deux armes à deux mains » ?**
Dans le domaine côté Java, en garantie d'intégrité ; la validation Angular n'est qu'un confort. Une règle uniquement dans l'IHM peut être contournée en appelant l'API directement.

**C'est quoi un index, et pourquoi en créer sur une clé étrangère ?**
Structure annexe (B-tree) qui évite de parcourir toute la table. PostgreSQL en crée sur les clés primaires mais pas sur les clés étrangères. Ma requête principale filtre par `warband_id`, donc je l'indexe. Je vérifie avec `EXPLAIN ANALYZE`, et j'évite de sur-indexer car chaque index coûte à l'écriture.

**Que se passe-t-il quand on supprime une bande ? une arme ?**
Bande : `CASCADE` sur ses guerriers (même agrégat). Arme : `RESTRICT` tant qu'elle est portée par un guerrier ou référencée, pour protéger le catalogue.

**Pourquoi deux interfaces, un port d'entrée et un port de sortie ?**
Le port d'entrée décrit ce que l'application offre, il est appelé par le contrôleur et implémenté par le service. Le port de sortie décrit ce dont le domaine a besoin, il est appelé par le service et implémenté par l'adaptateur JPA. Il appartient au domaine : c'est l'inversion de dépendances, l'infrastructure dépend du domaine.

**Pourquoi les entités JPA ne sont-elles pas des `record` ?**
JPA exige des classes non finales avec un constructeur sans argument, et Hibernate ne supporte pas les `record` comme entités. En hexagonal strict, de toute façon, le domaine (en `record`) et la persistance (en classes) sont deux modèles distincts reliés par un mapper.

**Pourquoi tes services n'ont-ils pas `@Service` ?**
Pour que la couche `application` ne dépende pas de Spring. Les services sont déclarés comme beans dans une classe `@Configuration` de l'infrastructure. Je connais le compromis : `@Service` est plus rapide à écrire mais couple la couche à Spring.

**Comment testes-tu ton cas d'usage ? Pourquoi Mockito ?**
Je mocke le port de sortie, jamais la classe testée. J'ai d'abord écrit un faux repository à la main pour comprendre le principe, puis comparé avec Mockito : moins de code, mais un `verify` qui couple le test à l'implémentation si on en abuse. Le mode strict détecte les `when` inutiles.

**Pourquoi un fichier YAML, et que fait `open-in-view: false` ?**
On externalise la configuration pour ne pas recompiler par environnement ni mettre de secrets dans le code, et les variables d'environnement surchargent le fichier. `open-in-view: false` ferme la session JPA à la fin de la couche service, ce qui évite de masquer des problèmes de lazy loading et de requêtes N+1.

**Qu'est-ce qui change avec Spring Boot 4 ?**
Les auto-configurations sont modularisées : il faut par exemple `spring-boot-starter-flyway` pour que Flyway s'exécute, et `spring-boot-starter-webmvc` remplace `spring-boot-starter-web`.

**Comment gères-tu la question des droits Games Workshop ?**
Projet gratuit, non monétisé, non officiel, sans asset de marque, avec mention claire de non-affiliation. Contenu de règles isolé dans des migrations de seed, donc facile à retirer ou réécrire.

**Qu'est-ce qui reste à faire ?**
La persistance JPA, l'API REST et le frontend du POC, les validations d'équipement côté domaine, les factions et le reste du contenu de règles (voir §9).
