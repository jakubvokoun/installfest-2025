# Nix/NixOS & secrets demo

```sh
export SOPS_AGE_KEY_FILE=$(pwd)/age-key.txt
sops edit secrets.yml
```

```sh
vagrant up
vagrant ssh
cp -r /vagrant/flake-config /home/vagrant/
sudo nixos-rebuild switch --flake /home/vagrant/flake-config#default
```

```sh
vagrant ssh
env | grep SECRET_API_KEY
```
