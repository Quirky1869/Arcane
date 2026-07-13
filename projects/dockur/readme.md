# Dockur

Avant de lancer la container il faut vérifier qu'on peut faire de la virtualisation 

```bash
ls -la /dev/kvm
# Puis vérifier qu'on a accès au group KVM
groups | grep kvm
# Si non, alors il faut ajouter notre user puis reboot
sudo usermod -aG kvm $USER
```
