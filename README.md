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

Copiez les résultats dans le fichier `.env` :

```bash
ENCRYPTION_KEY=<résultat de openssl rand -hex 16>
JWT_SECRET=<résultat de openssl rand -hex 32>
PROJECTS_PATH=</home/jason/docker>
```

Si vous ne souhaitez pas utiliser le container `Technitium (DNS self hosted)`, il faudra alors compléter votre fichier `/etc/hosts`  

>  [!TIP]  
> Équivalent Windows :  
> C:\Windows\System32\drivers\etc\hosts 

Exemple `/etc/hosts` :  

```bash
# Traefik
127.0.0.1   arcane.lab
127.0.0.1   backup-calc.lab
127.0.0.1   beszel.lab
127.0.0.1   convertx.lab
127.0.0.1   dozzle.lab
127.0.0.1   drawio.lab
127.0.0.1   excalidraw.lab
127.0.0.1   ffmpeg-web.lab
127.0.0.1   grafana.lab
127.0.0.1   heimdall.lab
127.0.0.1   it-tools.lab
127.0.0.1   macos.lab # dockur
127.0.0.1   netbox.lab
127.0.0.1   purple-spells.lab
127.0.0.1   rackula.lab
127.0.0.1   sqlitebrowser.lab
127.0.0.1   stirling.lab
127.0.0.1   traefik.lab
127.0.0.1   windows.lab # dockur
127.0.0.1   yt-dlp.lab
...
```

### 4. Lancer Arcane

```bash
sudo docker-compose up -d
```
> Si vous utilisez les containers (dont Arcane) avec Traefik, merci de démarrer le container "Traefik" en premier pour ne pas avoir l'erreur :  
> <span style=color:red;>network traefik-net declared as external, but could not be found</span>

### 5. Accéder à l'interface

Sans Traefik :  
[localhost:3552](http://127.0.0.1:3552)  

Avec Traefik :  
[arcane.lab](http://arcane.lab)  

**Identifiants par défaut :**  
- Utilisateur : `arcane`
- Mot de passe : `arcane-admin`

⚠️ **Il vous sera demandé de changer ce mot de passe immédiatement à la première connexion.** Ne pas le laisser par défaut  

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
      - ${PROJECTS_PATH}:/app/data/projects # Changez la variable PROJECTS_PATH dans le .env, elle doit ressembler à "/home/jason/docker"
    environment:
      - APP_URL=http://arcane.lab
      - PUID=1000 # À changer si besoin (commande : id -> résultat : uid)
      - PGID=1000 # À changer si besoin (commande : id -> résultat : gid)
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
      - '3552:3552'   # accès direct de secours (IP:port), le temps de mettre en place Technitium
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - arcane-data:/app/data
      - ${PROJECTS_PATH}:/app/data/projects # Changez la variable PROJECTS_PATH dans le .env, elle doit ressembler à "/home/jason/docker"
    environment:
      - APP_URL=http://arcane.lab
      - PUID=1000 # À changer si besoin (commande : id -> résultat : uid)
      - PGID=1000 # À changer si besoin (commande : id -> résultat : gid)
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

>  Le volume `${PROJECTS_PATH}:/app/data/projects` (qui se gère dans `.env`) doit pointer vers le dossier contenant tous vos projets Docker. Adaptez le chemin à votre propre nom d'utilisateur et à l'emplacement réel de votre dossier `~/docker`

## Gérer les mises à jour d'Arcane

```bash
cd Arcane  
sudo docker-compose pull  
sudo docker-compose up -d  
```

Ou directement depuis l'interface Arcane via le bouton "Update available" quand une nouvelle version est disponible  

---

## clone-copy-repos-docker.sh

```bash
chmod u+x clone-copy-repos-docker.sh
./clone-copy-repos-docker.sh
```

Ce script permet de cloner automatiquement des projets Docker via GitHub en une seule commande, pratique pour redéployer rapidement toute une stack de projets sur une nouvelle machine.

Pour les projets sans dépôt particulier, des `docker-compose.yml` sont créés dans `Arcane/projects` puis copiés dans `~/docker` avec `./clone-copy-repos-docker.sh`.

### Comment ça marche

- La liste des dépôts à cloner se trouve tout en haut du script, dans le tableau `REPOS`
- Le script détecte automatiquement le dossier dans lequel il se trouve, puis clone chaque dépôt dans le **dossier parent** (`~/docker`), peu importe d'où le script est lancé
- Si un dossier existe déjà, le script le **saute automatiquement** pour ne rien écraser
- Compatible avec les URLs en SSH (`git@github.com:...`) et en HTTPS (`https://github.com/...`)
- Le script copie aussi le contenu de `Arcane/projects` dans `~/docker`

### Ajouter un nouveau dépôt

Il suffit d'ajouter une ligne dans le tableau `REPOS` en haut du script :

```bash
REPOS=(
    "git@github.com:Quirky1869/Purple-Spells.git"
    "https://github.com/Quirky1869/backup-calculator.git"
    "https://github.com/mon-user/mon-projet.git"
)
```
Tous les dépôts listés seront clonés directement dans `~/docker/`

### Container avec readme

Certains containers ont un `readme.md` qui leur est propre, soit pour la création de dossiers, soit pour la création de fichier `.env`, ou autre.

Voici les containers concernés :
- Authelia
- Dockur-Windows
- Grafana
- Netbox
- Rackula
- Technitium
- Yt-dlp