# Nix/NixOS & secrets

> Jakub Vokoun
> jakub.vokoun@wftech.cz

---
# Motivace

- **deklarativní**, **reprodukovatelná**, **bezpečná** a **verzovaná** konfigurace systému
- zakládní prvky:
    - NixOS
    - Flakes
    - Home Manager
    - sops-nix

---

# Nix 101

## Nix

- jazyk
- CLI nástroj
- operační systém

---

# Nix 101

## Jazyk Nix

- dynamicky typovaný
- funkcionální
- lazy evaluation
- DSL (Domain Specific Language)

---

# Nix 101

## Flakes

> Nix flakes provide a standard way to write Nix expressions (and therefore packages) whose dependencies are version-pinned in a lock file, improving reproducibility of Nix installations. (https://nixos.wiki/wiki/Flakes)

- `flake.nix`
- `falke.lock`

---

# Nix 101

## Flakes

```sh
nix flake init
```

```sh
nix flake init --experimental-features 'nix-command flakes'
```

```sh
cd /etc/nixos
sudo nix flake init --template github:username/flake-starter-config
```

---

# Nix 101

## Flakes

```nix
{
  description = "Nixos config flake";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        #./my-module.nix
      ];
    };
  };
}
```

---

# Nix 101

## Flakes

```sh
sudo nixos-rebuild switch --flake /etc/nixos/#default
```

---

# Nix 101

## Flakes

```sh
nix flake info
```

```sh
nix flake metadata foo --json | jq .
```

```sh
nix flake metadata foo
```

```sh
nix flake update
```

---

# SOPS 101

- Secrets OPerationS
- formáty: **YAML**, JSON, ENV, INI, BINARY 
- šifuje pomocí: AWS KMS, GCP KMS, Azure Key Vault, PGP, age
- široké spektrum použití:
    - CLI
    - Terraform provider
    - k8s operátor
    - ...
    - sops-nix

---

# SOPS 101

```sh
nix-shell -p age sops
```

```sh
age-keygen -o age-key.txt
age-keygen -y age-key.txt
```

---

# SOPS 101

```yml
# .sops.yaml
keys:
  - &primary age13tl7p3xy6fwxgwfp5dtflpm7teag56mwy932xka4d2ujcfe9weusttlm9p
creation_rules:
  - path_regex: secrets.yaml$
    key_groups:
    - age:
      - *primary
```

```sh
sops edit secrets.yaml
```

---

# sops-nix 101

```nix
# configuration.nix
{ pkgs, inputs, config, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = /home/user/repos/secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/user/.config/sops/age/keys.txt";

  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = { owner = "sometestservice"; };
}
```

---

# sops-nix 101

```nix
# flake.nix
{
  description = "System configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      nixosConfigurations = {
        your-hostname = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./configuration.nix ];
        };
      };
    };
}
```

---

# sops-nix 101


```nix
# flake.nix
{
  description = "System configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.default
            {
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
              home-manager.useUserPackages = true;
              home-manager.users.vagrant = import ./home.nix;
            }
          ];
        };
      inputs.nixpkgs.follows = "nixpkgs";
    };
      };
    };
}
```

---
 
# sops-nix 101

```nix
# home.nix
{ inputs, lib, config, pkgs, ... }: {
  sops = {
    age.keyFile = "/home/vagrant/flake-config/keys.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets.secret_api_key = {
      path = "${config.sops.defaultSymlinkPath}/secret_api_key";
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export SECRET_API_KEY="$(cat ${config.sops.secrets.secret_api_key.path})"
    '';
  };
}
```

---
# Demo

---

# Refrence

- https://nix-community.github.io/home-manager/
- https://github.com/nix-community/home-manager
- https://github.com/Mic92/sops-nix
- https://github.com/getsops/sops
