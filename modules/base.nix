{ pkgs, ... }: {
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    git-crypt
    rustdesk-server
    anydesk
  ];
  fonts.fontconfig.enable = true;

  programs.command-not-found.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
  };

  system.stateVersion = "26.05";
}
