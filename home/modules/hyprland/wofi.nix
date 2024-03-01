{ pkgs, ... }:
let
  style = pkgs.writeText "wofi-style" ''
    * {
      font-size: 20px;
    }

    window {
      border-radius: 20px;
      background-color: rgba(75, 75, 75, 0.3);
    }

    #outer-box {
      margin: 5px;
      padding: 5px;
    }

    #scroll {
      margin: 5px;
      padding: 10px;
      border: none;
      border-radius: 20px;
      background-color: rgba(255, 255, 255, 0.1);
    }

    #input {
      color: white;
      caret-color: white;
      padding: 5px 20px;
      margin: 5px;
      border-radius: 20px;
      background-color: rgba(255, 255, 255, 0.1);
      animation: fadeIn 0.5s ease-in-out both;
      box-shadow: none;
      border-color: transparent;
    }

    #input image {
      border: none;
      color: white;
    }

    #text {
      margin: 5px;
      border: none;
      color: white;
      animation: fadeIn 0.5s ease-in-out both;
    }

    #entry:selected {
      background-color: rgba(255, 255, 255, 0.2);
      border-radius: 20px;
      outline: none;
    }
  '';

in {
  programs.wofi = { enable = true; };
  xdg.configFile."wofi/style.css".source = style;
}
