{ pkgs, ... }: { home.packages = with pkgs; [ (nixGL lutris) ]; }
