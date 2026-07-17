# MKCERT

mkcert va nous permettre de créer notre propre CA (certificat d'autorité) pour pouvoir avec de l'HTTPS et pouvoir ensuite créer un domaine à 2 niveaux : home.lab au lieu de .lab  

Installer mkcert sur votre hôte  
```bash
- Arch : sudo pacman -S mkcert --noconfirm
- Debian : sudo apt install libnss3-tools -y && curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && chmod +x mkcert-v*-linux-amd64 && sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
- Red Hat/Fedora : sudo dnf install nss-tools -y && curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && chmod +x mkcert-v*-linux-amd64 && sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
```

Lancer ensuite cette commande pour générer un nouveaux CA local :
```bash
mkcert -install
```

Les CA se trouve dans : `~/.local/share/mkcert/`  

Il faudra ensuite fermer et rouvrir vos navigateur web  

Créer ensuite un dossier "certs" dans votre dossier "traefik" :
```bash
mkdir -p ~/docker/Arcane/projects/traefik/certs
```

Ensuite on génére un certificat wildcard pour couvrir tous les container d'un coup :
```bash
cd ~/docker/Arcane/projects/traefik/certs
mkcert "*.home.lab" "home.lab"
```
Ça va créer 2 fichiers : un .pem (le certificat) et un -key.pem (la clé privée)  

La validité du certificat est fixé à 825 jours non modifiable  

Un dossier "dynamic" dans votre dossier "traefik" est déjà créer:
```bash
mkdir -p ~/docker/Arcane/projects/traefik/dynamic
```
A l'interieur de ce dossier il y a un fichier tls.yml qui ressemble à ceci :
```yaml
tls:
  certificates:
    - certFile: /certs/_wildcard.home.lab+1.pem
      keyFile: /certs/_wildcard.home.lab+1-key.pem
```
> [!CAUTION]
> Vérifier les noms des certificats `.pem` et `-key.pem`

Relancer le container traefik si besoin ou démarrer le :
```bash
sudo docker-compose down
sudo docker-compose up --build -d
```

Aller ensuite sur `Technitium` et ajouter une zone (voir le [readme.md](../technitium/readme.md) de Technitium) :
- Type : Primary zone
- Nom de la zone : home.lab

Il faut ensuite rentrer les enregistrements de vos containers : un import est possible avec le fichier `home.lab.zone` (Changer les adresses IP dans le fichier pour quelles correpsondent au serveur qui heberge traefik ⚠️ ne pas mettre 127.0.0.1)  

Maintenant traefik écoute sur le port 443 -> Il est possible dans le docker-compose.yml de traefik d'enlever le port 80  

Tester la connexion avec traefik : https://traefik.home.lab/  

Vérifier que les docker-compose.yml des containers sont tous lancés sur le paramétrage "Avec mkcert"  
