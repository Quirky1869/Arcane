![arcane](./_images/arcane.png)

## 🇬🇧 English

# Docker Stack

This repository gathers all my Docker stacks (Arcane, Purple-Spells, backup-calculator, it-tools, sqlite-browser, etc.), managed and deployed via [Arcane](https://getarcane.app/)

## Structure

```
~/docker/
├── Arcane/
│   ├── _images/
│   ├── projects/
│   ├── docker-compose.yml
│   ├── .env              # not versioned, contains secrets
│   ├── .env.example
│   ├── clone-copy-repos-docker.sh
│   ├── LICENSE
│   └── README.md
```

## Deployment workflow

> **Traefik**: Reverse Proxy
> **Technitium**: Self-hosted DNS
> **Mkcert**: Certificate generation (HTTPS)

> [!CAUTION]
> Several .yml files are present in the `projects/*` folders
> The infrastructure can be configured in several ways, see below

> [!TIP]
> By default the infrastructure is configured to work with Traefik, Technitium, and mkcert
> If you want to run the infra in a different way, please follow the instructions below and rename the corresponding files in `projects/*`
> <b><u>Example:</u></b>
> ```
> mv projects/it-tools/docker-compose.yml projects/it-tools/docker-compose.yml.ori
>
> mv projects/it-tools/docker-compose-raw.yml projects/it-tools/docker-compose.yml
> ```

___

### Without Traefik, Technitium, and mkcert

**Files involved: docker-compose-raw.yml**

Deploy the infra by following this README.md

Access to the container will be via your loopback IP address + port

E.g.: http://127.0.0.1:9080

___

### With Traefik

**Files involved: docker-compose-with-traefik-and-or-technitium.yml**

- Start the Traefik container first to create the network: `traefik-net`
- For the desired containers, rename the file `docker-compose-with-traefik-and-or-technitium.yml` to `docker-compose.yml`
- Edit your `/etc/hosts` file (you can follow the example further down in this README.md)
- Start your containers (it-tools, convertX, dozzle, homepage, etc.)

Access will then be via the name you set in the `/etc/hosts` file + TLD (over http)

E.g.: http://netbox.lab/

___

### With Traefik and Technitium

**Files involved: docker-compose-with-traefik-and-or-technitium.yml**

- Start the Traefik container first to create the network: `traefik-net`
- For the desired containers, rename the file `docker-compose-with-traefik-and-or-technitium.yml` to `docker-compose.yml`

> [!NOTE]
> - The goal is to use a self-hosted DNS instead of editing your `/etc/hosts` file locally

- To configure Technitium, please follow the "readme.md" procedure in the `projects/technitium` folder - [Procedure here](./projects/technitium/readme.md)

Access will then be via the A records set in Technitium + TLD (over http) in the "lab" zone

E.g.: http://beszel.lab/

___

### With Traefik, Technitium, and mkcert

**Files involved: docker-compose.yml**

> [!NOTE]
> - This is how the infrastructure was originally designed: to work with a reverse proxy (Traefik), a DNS (Technitium), and a certificate generator (mkcert)
> - The `docker-compose.yml` files intentionally expose their ports as a backup solution, but once all tests have been performed and validated, it is preferable to remove the "ports:" lines

- Please follow the "With Traefik" and "With Traefik and Technitium" deployments above
- Once done, the goal is to create a two-level domain and have our pages served over https, e.g.: https://convertx.home.lab
- Please follow the [mkcert procedure](./projects/mkcert/readme.md)

Access will then be via the A records set in Technitium + TLD (over https) in the "home.lab" zone

E.g.: https://traefik.home.lab

## Installing Arcane

### 1. Clone the repository

```bash
git clone git@github.com:Quirky1869/Arcane.git
cd Arcane
chmod u+x clone-copy-repos-docker.sh
./clone-copy-repos-docker.sh
```

### 2. Create the environment file

```bash
cp .env.example .env
```

### 3. Generate the security keys

```bash
openssl rand -hex 16    # for ENCRYPTION_KEY (32 characters)
openssl rand -hex 32    # for JWT_SECRET
```

Copy the results into the `.env` file:

```bash
ENCRYPTION_KEY=<result of openssl rand -hex 16>
JWT_SECRET=<result of openssl rand -hex 32>
PROJECTS_PATH=</home/jason/docker>
```
> [!TIP]
> If you want to use `Technitium (self-hosted DNS)`, it is recommended to read the [readme.md](./projects/technitium/readme.md) specific to Technitium + start the Technitium container third, after Traefik (mandatory with Technitium) and Arcane

If you do not want to use the `Technitium (self-hosted DNS)` container, you will need to fill in your `/etc/hosts` file

> [!TIP]
> Windows equivalent:
> C:\Windows\System32\drivers\etc\hosts

Example `/etc/hosts`:

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

### 4. Start Arcane

```bash
sudo docker-compose up -d
```
> [!CAUTION]
> If you use the containers (including Arcane) with Traefik, please start the "Traefik" container first to avoid the error:
> <span style=color:red;>network traefik-net declared as external, but could not be found</span>

### 5. Access the interface

Without Traefik:
[localhost:3552](http://127.0.0.1:3552)

With Traefik:
[arcane.lab](http://arcane.lab)

**Default credentials:**
- User: `arcane`
- Password: `arcane-admin`

⚠️ **You will be asked to change this password immediately on first login.** Do not leave it as default

## Arcane's docker-compose.yml without Traefik

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
      - ${PROJECTS_PATH}:/app/data/projects # Change the PROJECTS_PATH variable in .env, it should look like "/home/jason/docker"
    environment:
      - APP_URL=http://arcane.lab
      - PUID=1000 # Change if needed (command: id -> result: uid)
      - PGID=1000 # Change if needed (command: id -> result: gid)
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped
volumes:
  arcane-data:
```

> The `${PROJECTS_PATH}:/app/data/projects` volume (set in `.env`) must point to the folder containing all your Docker projects. Adapt the path to your own username and the actual location of your `~/docker` folder

## Managing Arcane updates

```bash
cd Arcane
sudo docker-compose pull
sudo docker-compose up -d
```

Or directly from the Arcane interface via the "Update available" button when a new version is available

---

## clone-copy-repos-docker.sh

```bash
chmod u+x clone-copy-repos-docker.sh
./clone-copy-repos-docker.sh
```

This script automatically clones Docker projects from GitHub in a single command, handy for quickly redeploying a whole stack of projects on a new machine.

For projects without a dedicated repository, `docker-compose.yml` files are created in `Arcane/projects` then copied into `~/docker` via `./clone-copy-repos-docker.sh`.

### How it works

- The list of repositories to clone is at the very top of the script, in the `REPOS` array
- The script automatically detects the folder it's located in, then clones each repository into the **parent folder** (`~/docker`), regardless of where the script is run from
- If a folder already exists, the script **automatically skips it** so nothing gets overwritten
- Compatible with SSH URLs (`git@github.com:...`) and HTTPS URLs (`https://github.com/...`)
- The script also copies the contents of `Arcane/projects` into `~/docker`

### Adding a new repository

Simply add a line to the `REPOS` array at the top of the script:

```bash
REPOS=(
    "git@github.com:Quirky1869/Purple-Spells.git"
    "https://github.com/Quirky1869/backup-calculator.git"
    "https://github.com/mon-user/mon-projet.git"
)
```
All listed repositories will be cloned directly into `~/docker/`

## Containers with a readme

Some containers have their own `readme.md`, whether for creating folders, creating a `.env` file, or other purposes

Here are the containers concerned:
- Authelia
- Dockur-Windows
- Grafana
- Mkcert
- Netbox
- Rackula
- Technitium
- Yt-dlp

## Named volumes

The location of named volumes (present in several docker-compose.yml files) is found on your host at:
```
/var/lib/docker/volumes/
```

---

## 🇫🇷 Français

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
> Plusieurs fichiers .yml sont présents dans les dossiers `projects/*`  
> L'infrastructure peut être configurée de plusieurs façons, voir ci-dessous  

> [!TIP]  
> Par défaut l'infrastructure est configurée pour fonctionner avec Traefik, Technitium et mkcert  
> Si vous souhaitez faire fonctionner l'infra d'une autre façon, merci de suivre les indications ci-dessous et de renommer les fichiers correspondants dans `projects/*`  
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

Les accès au container se feront via votre adresse IP loopback + port  

Ex : http://127.0.0.1:9080   

___  

### Avec Traefik

**Fichiers concernés : docker-compose-with-traefik-and-or-technitium.yml**  

- Lancer le container Traefik en premier afin de créer le réseau : `traefik-net`  
- Renommer, pour les containers voulus, le fichier `docker-compose-with-traefik-and-or-technitium.yml` en `docker-compose.yml`  
- Modifier votre fichier `/etc/hosts` (vous pouvez suivre l'exemple plus bas dans ce README.md) 
- Lancer vos containers (it-tools, convertX, dozzle, homepage etc...)

L'accès se fera ensuite via votre nom renseigné dans le fichier `/etc/hosts` + TLD (en http)  

Ex : http://netbox.lab/  

___  

### Avec Traefik et Technitium

**Fichiers concernés : docker-compose-with-traefik-and-or-technitium.yml**  

- Lancer le container Traefik en premier afin de créer le réseau : `traefik-net`  
- Renommer, pour les containers voulus, le fichier `docker-compose-with-traefik-and-or-technitium.yml` en `docker-compose.yml` 

> [!NOTE]
> - Le but est de passer par un DNS self hosted au lieu de modifier localement votre fichier `/etc/hosts` 

- Pour paramétrer Technitium veuillez suivre la procédure "readme.md" dans le dossier `projects/technitium` - [Procédure ici](./projects/technitium/readme.md) 

L'accès se fera ensuite via les hôtes A renseignés dans Technitium + TLD (en http) dans la zone "lab"  

Ex : http://beszel.lab/  

___  

### Avec Traefik, Technitium et mkcert

**Fichiers concernés : docker-compose.yml**  

> [!NOTE]  
> - C'est la façon dont l'infrastructure a été pensée au départ : fonctionner avec un reverse proxy (Traefik), un DNS (Technitium) et un générateur de certificats (mkcert)
>- Les fichiers `docker-compose.yml` exportent volontairement leurs ports en solution de backup mais une fois tous les tests effectués et validés, il est préférable de supprimer les lignes "ports:"  

- Merci de suivre ci-dessus les déploiements "Avec Traefik" et "Avec Traefik et Technitium"
- Une fois fait, le but est de créer un domaine à deux niveaux et d'avoir nos pages en https, ex : https://convertx.home.lab
- Merci de suivre la [procédure mkcert](./projects/mkcert/readme.md)    

L'accès se fera ensuite via les hôtes A renseignés dans Technitium + TLD (en https) dans la zone "home.lab"  

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

## Container avec readme

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

## Named volumes

L'emplacement des named volumes (présent dans plusieurs docker-compose.yml) se trouve sur votre hôte à cet emplacement :
```
/var/lib/docker/volumes/
```
