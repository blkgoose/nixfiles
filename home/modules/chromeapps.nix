{
  lib,
  pkgs,
  config,
  ...
}:
let
  house_ip = pkgs.secret "house_local_ip";

  personal = [ "--profile-directory='Default'" ];
  unsafe = [
    "--disable-web-security --user-data-dir=${config.xdg.configHome}/unsafe-chrome"
  ];
  no_plugins = [
    "--disable-extensions"
    "--disable-plugins"
  ];

  chromeWrapper =
    opts: url:
    let
      chrome = with pkgs; "${(nixGL google-chrome)}/bin/google-chrome-stable";
      spacedOpts = lib.strings.concatStringsSep " " opts;
    in
    ''
      ${chrome} --app='${url}' --new-window ${spacedOpts}
    '';

  apps = {
    "amazon" = {
      url = "https://amazon.it";
      wrapper = chromeWrapper personal;
    };
    "bambustore" = {
      url = "https://eu.store.bambulab.com/";
      wrapper = chromeWrapper personal;
    };
    "books" = {
      url = "https://play.google.com/books";
      wrapper = chromeWrapper personal;
    };
    "calendar".url = "https://calendar.google.com/calendar";
    "chess" = {
      url = "https://www.chess.com";
      wrapper = chromeWrapper personal;
    };
    "claude-ai" = {
      url = "https://claude.ai/code";
      wrapper = chromeWrapper personal;
    };
    "coggle".url = "https://coggle.it";
    "coronavisual".url = "https://blkgoose.github.io/coronavisual";
    "cronometer" = {
      url = "https://cronometer.com/#diary";
      wrapper = chromeWrapper personal;
    };
    "crunchyroll" = {
      url = "https://www.crunchyroll.com/it";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "disney" = {
      url = "https://disneyplus.com";
      wrapper = chromeWrapper personal;
    };
    "elm-search" = {
      url = "https://klaftertief.github.io/elm-search/";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "facebook" = {
      url = "https://www.facebook.com";
      wrapper = chromeWrapper personal;
    };
    "github".url = "https://github.com";
    "gemini" = {
      url = "https://gemini.google.com";
    };
    "gmail".url = "https://mail.google.com";
    "hackernews" = {
      url = "https://hckrnews.com/";
      wrapper = chromeWrapper personal;
    };
    "home-assistant" = {
      url = "http://${house_ip}:8123";
      wrapper = chromeWrapper personal;
    };
    "hutch-localhost" = {
      url = "http://localhost:3000";
      wrapper = chromeWrapper unsafe;
    };
    "hm-search" = {
      url = "https://home-manager-options.extranix.com/";
      wrapper = chromeWrapper personal;
    };
    "instagram" = {
      url = "https://instagram.com";
      wrapper = chromeWrapper personal;
    };
    "keep" = {
      url = "https://keep.google.com";
      wrapper = chromeWrapper personal;
    };
    "maps" = {
      url = "https://www.google.it/maps/preview";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "messages" = {
      url = "https://messages.google.com/web/conversations";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "netflix" = {
      url = "https://www.netflix.com";
      wrapper = chromeWrapper personal;
    };
    "news" = {
      url = "https://news.google.it";
      wrapper = chromeWrapper personal;
    };
    "nix-search" = {
      url = "https://search.nixos.org/packages";
      wrapper = chromeWrapper personal;
    };
    "nix-rev" = {
      url = "https://lazamar.co.uk/nix-versions";
      wrapper = chromeWrapper personal;
    };
    "noogle" = {
      url = "https://www.noogle.dev";
      wrapper = chromeWrapper personal;
    };
    "onshape" = {
      url = "https://cad.onshape.com";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "paint" = {
      url = "https://jspaint.app/";
    };
    "perplexity" = {
      url = "https://www.perplexity.ai/";
      wrapper = chromeWrapper personal;
    };
    "photos" = {
      url = "https://photos.google.com";
      wrapper = chromeWrapper personal;
    };
    "primevideo" = {
      url = "https://www.primevideo.com";
      wrapper = chromeWrapper personal;
    };
    "printables" = {
      url = "https://www.printables.com";
      wrapper = chromeWrapper personal;
    };
    "prozis" = {
      url = "https://www.prozis.com/it/it";
      wrapper = chromeWrapper personal;
    };
    "reddit" = {
      url = "https://reddit.com";
      wrapper = chromeWrapper personal;
    };
    "rp-app" = {
      url = "https://training.rpstrength.com/";
      wrapper = chromeWrapper personal;
    };
    "sheets".url = "https://docs.google.com/spreadsheets";
    "telegram" = {
      url = "https://web.telegram.org/k/";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "trakt" = {
      url = "https://app.trakt.tv/";
      wrapper = chromeWrapper personal;
    };
    "trello" = {
      url = "https://www.trello.com";
      wrapper = chromeWrapper personal;
    };
    "wallet" = {
      url = "https://web.budgetbakers.com/dashboard";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "whatsapp" = {
      url = "https://web.whatsapp.com/";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "xbox" = {
      url = "https://xbox.com/play";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "youtube" = {
      url = "https://youtube.com";
      wrapper = chromeWrapper personal;
    };
  };

  mkWrappedApp =
    name:
    {
      url,
      wrapper ? chromeWrapper [ ],
    }:
    {
      name = ".local/bin/${name}";
      value = {
        text = ''
          #!/usr/bin/env bash

          ${(wrapper url)}
        '';
        executable = true;
      };
    };
in
{
  home.file = lib.attrsets.mapAttrs' mkWrappedApp apps;
}
