Pour connecter ton Zabbix existant (la VM)
Grafana n'a pas de plugin Zabbix natif intégré, il faut l'ajouter. Deux façons :
1. Via variable d'env (le plus simple, à l'install)

```yaml
yaml    environment:
      - GF_INSTALL_PLUGINS=alexanderzobnin-zabbix-app
```

2. Via CLI dans le conteneur après coup
```bash
bashdocker exec -it grafana grafana-cli plugins install alexanderzobnin-zabbix-app
docker restart grafana
```

Ensuite dans l'UI Grafana : Connections > Data sources > Add data source > Zabbix, tu renseignes l'URL de l'API Zabbix de ta VM (genre http://ip-de-ta-vm/zabbix/api_jsonrpc.php) + les identifiants Zabbix. Rien à changer côté Zabbix, il expose déjà son API par défaut.
Points d'attention réseau

Ton conteneur Grafana doit juste pouvoir joindre la VM Zabbix sur le réseau (port 80/443 de l'interface web Zabbix). Pas besoin de réseau Docker spécial, un bridge classique suffit tant que la VM est accessible depuis l'hôte Docker.
Si Zabbix est en HTTPS avec un certif auto-signé, il faudra désactiver la vérification TLS côté datasource Grafana ou lui donner le certif.
