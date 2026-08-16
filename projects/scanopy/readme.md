# Il faut générer dans un .env un mot de passe pour postgres
cd ~/docker/Arcane/projects/scanopy
echo "POSTGRES_PASSWORD=$(openssl rand -hex 16)" > .env

