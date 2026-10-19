# Mordheim Builder

Utilitaire web **gratuit** de création de liste d'armée pour Mordheim, jeu de figurines dont le support officiel est arrêté.

> **Projet fan non officiel, non affilié à Games Workshop.** Mordheim, Warhammer et les marques associées appartiennent à Games Workshop Ltd. Ce projet est gratuit, sans but lucratif, et n'utilise aucun logo ni illustration officiels.

Projet personnel d'apprentissage : architecture hexagonale (Java / Spring Boot), Angular 20, PostgreSQL et migrations Flyway.

## État d'avancement

| Élément | État |
|---|---|
| Schéma PostgreSQL + migrations Flyway (V1 à V7) | Réalisé |
| Catalogue de règles spéciales et d'armes | Réalisé |
| Backend Spring Boot (hexagonal) | À venir |
| Frontend Angular 20 | À venir |

## Documentation

La conception détaillée (modèle de données, décisions et justifications, règles métier, feuille de route) est dans [`docs/conception.md`](docs/conception.md).

## Démarrage rapide (base de données)

Prérequis : Docker, et le client [Flyway CLI](https://flywaydb.org/).

```bash
docker compose up -d                        # PostgreSQL 16 sur le port 5432
flyway -configFiles=flyway.conf migrate     # applique les migrations de db/migration
```

Vérification :

```bash
docker exec -it mordheim-postgres psql -U mordheim -d mordheim_builder -c "\dt"
```

Les identifiants fournis sont ceux d'un environnement de **développement local** uniquement.

## Structure du dépôt

```
mordheim-builder/
├── README.md
├── docker-compose.yml
├── flyway.conf
├── docs/
│   └── conception.md
└── db/
    └── migration/        # V1 à V7 (déplacé dans le backend à l'étape suivante)
```
