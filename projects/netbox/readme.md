M Netbox

Il faut créer un .env

```bash
cp .env.example .env
# ou
touch .env
```

```bash
echo "NETBOX_API_TOKEN=$(openssl rand -hex 20)" > .env
echo "NETBOX_ADMIN_PASSWORD=$(openssl rand -hex 12)" >> .env
echo "NETBOX_DB_PASSWORD=$(openssl rand -hex 16)" >> .env
echo "NETBOX_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")" >> .env
# ou sans python
# echo "NETBOX_SECRET_KEY=$(openssl rand -base64 50 | tr -d '\n')" >> .env
```

Le 1er demarrage est long TREEEEES LONG (10-15 min)

```bash
# Pour suivre les logs
sudo docker compose logs -f netbox
```
Dans les logs on peut voir la fin grace à la ligne :
```
STDOUT
[INFO] Started worker-3
STDOUT
[INFO] Started worker-1
STDOUT
[INFO] Started worker-2
STDOUT
[INFO] Started worker-4
```

Identifiant : admin
Mot de passe : il est défini dans .env NETBOX_ADMIN_PASSWORD