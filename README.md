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

## Workflow de déploiement

> **Traefik** : Reverse Proxy  
> **Technitium** : DNS Self hosted  
> **Mkcert** : Génération de certificats (HTTPS)

> [!CAUTION]  
> Plusieurs fichiers .yml sont présent dans les dossiers `projects/*`  
> L'infrastructure peut être configurée de plusieurs façon, voir ci-dessous  

> [!TIP]  
> Par défaut l'infrastructure est configurée pour fonctionnée avec Traefik, Technitium et mkcert  
> Si vous souhaiter faire fonctionner l'infra d'une autre façon merci suivre les indications ce dessous et de renommer les fichiers correspondant dans `projects/*`  
> <b><u>Exemple :</u></b>  
> ```
> mv projects/it-tools/docker-compose.yml projects/it-tools/docker-compose.yml.ori
>  
> mv projects/it-tools/docker-compose-raw.yml projects/it-tools/docker-compose.yml   
> ```

___  

### Sans Traefik, Technitium et mkcert

**Fichiers concernés : docker-compose-raw.yml**  

Déployer l'infra en suivant ce README.md  

Les accès au container se feront via votre adresse ip loopbak + port  

Ex : http://127.0.0.1:9080   

___  

### Avec Traefik

**Fichiers concernés : docker-compose-with-traefik-and-or-technitium.yml**  

- Lancer le container Traefik en premier afin de créer le réseau : `traefik-net`  
- Renommer les `docker-compose-with-traefik-and-or-technitium.yml` en `docker-compose.yml` des containers voulus  
- Modifier votre fichier `/etc/hosts` (vous pouvez suivre l'exemple plus bas dans ce README.md) 
- Lancer vos containers (it-tools, convertX, dozzle, homepage etc...)

L'accès se fera ensuite via votre nom renseigner dans le fichier `/etc/hosts` + TLD (en http)  

Ex : http://netbox.lab/  

___  

### Avec Traefik et Technitium

**Fichiers concernés : docker-compose-with-traefik-and-or-technitium.yml**  

- Lancer le container Traefik en premier afin de créer le réseau : `traefik-net`  
- Renommer les `docker-compose-with-traefik-n-technitium.yml` en `docker-compose.yml` des containers voulus 

> [!NOTE]
> - Le but est de passer par un DNS self hosted au lieu de modifier localement votre fichier `/etc/hosts` 

- Pour paramétrer Technitium veuillez suivre la procédure "readme.md" dans le dossier `projects\technitium` - [Procédure ici](./projects/technitium/readme.md) 

L'accès se fera ensuite via les hôtes A renseignés dans Technitium + TLD (en http)  

Ex : http://beszel.lab/  

___  

### Avec Traefik, Technitium et mkcert

**Fichiers concernés : docker-compose.yml**  

> [!NOTE]  
> - C'est la façon dont l'infrastructure a été pensée au départ, fonctionner avec un reverse proxy (Traefik), un DNS (Technitium) et un générateur de certificats (mkcert)
>- Les fichiers `docker-compose.yml` export volontairement leurs ports en solution de backup mais une fois tous les tests effectués et validés il est préférable de supprimer les lignes "ports:"  

- Merci de suivre ci-dessus les déploiements "Avec Traefik" et "Avec Traefik et Technitium"
- Une fois fait le but est de créer un domaine à deux niveaux et d'avoir nos pages en https, ex : https://convertx.home.lab
- Merci de suivre la [procédure mkcert](./projects/mkcert/readme.md)    

Ex : https://traefik.home.lab   

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
>  [!TIP]  
> Si vous souhaitez utiliser `Technitium (DNS self hosted)`, il est conseillé de lire le [readme.md](./projects/technitium/readme.md) spécifique à Technitium + démarrer le container Technitium en troisième après Traefik (obligatoire avec Technitium) et Arcane  

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
127.0.0.1   homepage.lab
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
> [!CAUTION]
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

Certains containers ont un `readme.md` qui leur est propre, soit pour la création de dossiers, soit pour la création de fichier `.env`, ou autre

Voici les containers concernés :
- Authelia
- Dockur-Windows
- Grafana
- Mkcert
- Netbox
- Rackula
- Technitium
- Yt-dlp
