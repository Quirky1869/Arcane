# Dockur

Avant de lancer la container il faut vérifier qu'on peut faire de la virtualisation 

```bash
ls -la /dev/kvm
# Puis vérifier qu'on a accès au group KVM
groups | grep kvm
# Si non, alors il faut ajouter notre user puis reboot
sudo usermod -aG kvm $USER
```

Une fois windows installé on peut prendre la main via la page web et vnc sur le port : 8006

Soit via rdp : xfreerdp /u:jason /p:P@ssw0rd! /v:127.0.0.1 /cert:ignore /dynamic-resolution /scale-desktop:150 +clipboard
L'utilisateur et le mdp sont à adpater avec ceux du docker-compose.yml
