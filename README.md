# Arcane

![Arcane](./_images/arcane.png)  

# Docker Stack

Ce dépôt regroupe l'ensemble de mes stacks Docker (Arcane, Purple-Spells, backup-calculator, it-tools, sqlite-browser etc.), gérées et déployées via [Arcane](https://getarcane.app/)  

## Structure

```
~/docker/
├── Arcane/
│   ├── _images/
│   ├── projects/
│   ├── docker-compose.yml
│   ├── .env              # non versionné, contient les secrets
│   ├── .env.example
│   ├── clone-copy-repos-docker.sh
│   ├── LICENSE
│   └── README.md
```

## Installation d'Arcane

### 1. Cloner le dépôt

```bash
git clone git@github.com:Quirky1869/Arcane.git
cd Arcane
chmod u+x clone-copy-repos-docker.sh
./clone-copy-repos-docker.sh
```

### 2. Créer le fichier d'environnement

```bash
cp .env.example .env
```

### 3. Générer les clés de sécurité

```bash
openssl rand -hex 16    # pour ENCRYPTION_KEY (32 caractères)
openssl rand -hex 32    # pour JWT_SECRET
```

Copie les résultats dans le fichier `.env` :

```bash
ENCRYPTION_KEY=<résultat de openssl rand -hex 16>
JWT_SECRET=<résultat de openssl rand -hex 32>
```

### 4. Lancer Arcane

```bash
sudo docker-compose up -d
```
> Si vous utiliser les containers (dont Arcane) avec Traefik, merci de démmarer le container "Traefik" en premier pour ne pas avoir l'erreur :  
> network traefik-net declared as external, but could not be found

### 5. Accéder à l'interface

Sans Traefik :  
[localhost:3552](http://127.0.0.1:3552)  

Avec Traefik :  
[arcane.lab](http://arcane.lab)  

**Identifiants par défaut :**  
- Utilisateur : `arcane`
- Mot de passe : `arcane-admin`

⚠️ **Il te sera demandé de changer ce mot de passe immédiatement à la première connexion.** Ne le laisse pas par défaut.  

## docker-compose.yml d'Arcane sans Traefik

```yaml
services:
  arcane:
    image: ghcr.io/getarcaneapp/arcane:latest
    container_name: arcane
    ports:
      - '3552:3552'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - arcane-data:/app/data
      - /home/jason/docker:/app/data/projects # Changer l'utilisateur "jason" si besoin
    environment:
      - APP_URL=http://localhost:3552
      - PUID=1000
      - PGID=1000
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped
volumes:
  arcane-data:
```

## docker-compose.yml d'Arcane avec Traefik

```yaml
services:
  arcane:
    image: ghcr.io/getarcaneapp/arcane:latest
    container_name: arcane
    networks:
      - traefik-net
    ports:
      - '3552:3552'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - arcane-data:/app/data
      - /home/jason/docker:/app/data/projects # Changer l'utilisateur "jason" si besoin
    environment:
      - APP_URL=http://arcane.lab
      - PUID=1000
      - PGID=1000
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.arcane.rule=Host(`arcane.lab`)"
      - "traefik.http.services.arcane.loadbalancer.server.port=3552"

networks:
  traefik-net:
    external: true

volumes:
  arcane-data:
```

>  Le volume `/home/jason/docker:/app/data/projects` doit pointer vers le dossier contenant tous tes projets Docker (celui-ci). Adapte le chemin à ton propre nom d'utilisateur et à l'emplacement réel de ton dossier `~/docker`

## Exemple /etc/hosts 
> Equivalent Windows :  C:\Windows\System32\drivers\etc\hosts  
```bash
# Traefik
127.0.0.1   it-tools.lab
127.0.0.1   convertx.lab
127.0.0.1   drawio.lab
127.0.0.1   excalidraw.lab
127.0.0.1   grafana.lab
127.0.0.1   heimdall.lab
127.0.0.1   stirling.lab
127.0.0.1   backup-calc.lab
127.0.0.1   arcane.lab
127.0.0.1   purple-spells.lab
127.0.0.1   beszel.lab
127.0.0.1   ffmpeg-web.lab
127.0.0.1   sqlitebrowser.lab
127.0.0.1   dozzle.lab
127.0.0.1   auth.lab
127.0.0.1   rackula.lab
127.0.0.1   windows.lab # dockur
...
```

## Gérer les mises à jour

```bash
cd Arcane  
sudo docker-compose pull  
sudo docker-compose up -d  
```

Ou directement depuis l'interface Arcane via le bouton "Update available" quand une nouvelle version est disponible  

---

## clone-copy-repos-docker.sh

Ce script permet de cloner automatiquement tous mes projets Docker en une seule commande, pratique pour redéployer rapidement toute la stack sur une nouvelle machine

Pour les projets sans repo particulier des docker-compose.yml sont créer dans Arcane/projects puis sont copier dans ~/docker avec `clone-copy-repos-docker.sh`

### Comment ça marche

- La liste des dépôts à cloner se trouve tout en haut du script, dans le tableau `REPOS`.
- Le script détecte automatiquement le dossier dans lequel il se trouve, puis clone chaque dépôt dans le **dossier parent** (`~/docker`), peu importe d'où le script est lancé.
- Le nom du dossier créé pour chaque clone est déduit automatiquement de l'URL du dépôt (ex : `Purple-Spells.git` → dossier `Purple-Spells`).
- Si un dossier existe déjà, le script le **saute automatiquement** pour ne rien écraser.
- Compatible avec les URLs en SSH (`git@github.com:...`) et en HTTPS (`https://github.com/...`).
- Le script copie aussi le contenu de Arcane/projects dans ~/docker

### Ajouter un nouveau dépôt

Il suffit d'ajouter une ligne dans le tableau `REPOS` en haut du script :

```bash
REPOS=(
    "git@github.com:Quirky1869/Purple-Spells.git"
    "https://github.com/Quirky1869/backup-calculator.git"
    "https://github.com/mon-user/mon-nouveau-projet.git"
)
```

### Utilisation

```bash
cd ~/docker/
chmmod u+x clone-copy-repos-docker.sh
./clone-copy-repos-docker.sh
```

Tous les dépôts listés seront clonés directement dans `~/docker/`
