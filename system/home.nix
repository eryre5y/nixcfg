#OC: https://github.com/dan4ik605743/nix-config
{ config, pkgs, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ./doom.d;  # Directory containing your config.el init.el
                                # and packages.el files
      };

in

{
  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Reimu Hakurei";
      userEmail = "mikus1337112@gmail.com";
    };
  };

  home = {
    username = "reimu";
    homeDirectory = "/home/reimu";
    stateVersion = "21.05";
    packages = [
#      doom-emacs
    ];
    file.".emacs.d/init.el".text = ''
      (load "default.el")
    '';
  };
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  #home.username = "reimu";
  #home.homeDirectory = "/home/reimu";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #home.stateVersion = "21.05";
}
