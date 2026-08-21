# Il faut générer dans un .env un mot de passe pour postgres
cd ~/docker/Arcane/projects/scanopy  
echo "POSTGRES_PASSWORD=$(openssl rand -hex 16)" > .env  

Si un premier lancement a été effectué sans le .env alors le mot de passe de la BDD sera érroné, il faut supprimer le volume lié :
```bash
# On cherche les volumes lié à scanopy
sudo docker volume ls | grep scanopy

# On supprime le volume concerné
sudo docker volume rm scanopy_postgres_data

# Ensuite on peut rédéployer le projet
```
