# Authelia

## Afin de lancer authelia il faut générer les secrets nécessaire avant le lancement

```bash
# Pour construire les dossiers
mkdir ~/docker/Arcane/projects/authelia/redis/
mkdir ~/docker/Arcane/projects/authelia/secrets/
touch ~/docker/Arcane/projects/authelia/secrets/jwt_secret
touch ~/docker/Arcane/projects/authelia/secrets/session_secret
touch ~/docker/Arcane/projects/authelia/secrets/storage_key
```

```bash
# Pour générer les secrets et les mettre dans les 3 fichiers
openssl rand -hex 64 | tr -d '\n' > ~/docker/Arcane/projects/authelia/secrets/jwt_secret
openssl rand -hex 64 | tr -d '\n' > ~/docker/Arcane/projects/authelia/secrets/session_secret
openssl rand -hex 64 | tr -d '\n' > ~/docker/Arcane/projects/authelia/secrets/storage_key
```

## Il faut ensuite générer un hash d'un mot de passe (qu'on aura choisi lors de cette commande)
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'MOT_DE_PASSE_A_CHANGER'

Le hash généré sera à mettre dans `config/users_database.yml`

### Authelia est non fonctionnelle en l'état
