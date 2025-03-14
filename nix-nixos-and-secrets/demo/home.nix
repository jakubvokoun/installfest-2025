{ inputs, lib, config, pkgs, ... }: {
  imports = [ ];

  sops = {
    age.keyFile = "/home/vagrant/flake-config/age-key.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets.secret_api_key = {
      path = "${config.sops.defaultSymlinkPath}/secret_api_key";
    };
  };

  programs.bash = {
    enable = true;
    #bashrcExtra = ''
    #  export SECRET_API_KEY="$(cat ${config.sops.secrets.secret_api_key.path})"
    #'';
  };

  nixpkgs = {
    overlays = [ ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "vagrant";
    homeDirectory = "/home/vagrant";
  };

  home.packages = with pkgs; [ tmux vim yazi sops age ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}

