{ config, pkgs, lib, inputs, hostname, ... }:

let
  username = "paul";
in
{
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Application preferences
  imports = [
    ../../modules/fastfetch.nix
    ../../modules/git.nix
    ../../modules/ssh.nix
    ../../modules/vscode.nix
    ./fish.nix

    # Host-specific Home Manager settings (hosts/x1/home.nix, hosts/macbook/home.nix)
    (../../hosts + "/${hostname}/home.nix")
  ];

  # Home Manager release
  home.stateVersion = "24.11";

  # Basic packages that don't need dedicated modules
  home.packages = with pkgs; [
    htop
    ripgrep
    fastfetch
  ];

  # Dotfiles (if needed)
  home.file = {};

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
