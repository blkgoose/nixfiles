{ lib, pkgs, ... }:
let
  personal = [ "--profile-directory='Default'" ];
  work = [ "--profile-directory='Profile 1'" ];
  no_plugins = [ "--disable-extensions" "--disable-plugins" ];

  apps = {
    "amazon" = {
      url = "https://amazon.it";
      opts = personal;
    };
    "books" = {
      url = "https://play.google.com/books";
      opts = personal;
    };
    "calendar".url = "https://calendar.google.com/calendar";
    "chess".url = "https://www.chess.com";
    "codescene" = {
      url =
        "https://codescene.io/projects/35921/jobs/978159/results/code/hotspots/system-map";
      opts = work;
    };
    "coggle".url = "https://coggle.it";
    "coronavisual".url = "https://blkgoose.github.io/coronavisual";
    "crunchyroll" = {
      url = "https://www.crunchyroll.com/it";
      opts = personal ++ no_plugins;
    };
    "datadog" = {
      url = "https://app.datadoghq.eu/";
      opts = work;
    };
    "discord" = { url = "https://discord.com/channels/@me"; };
    "disney" = {
      url = "https://disneyplus.com";
      opts = personal;
    };
    "drone_ci" = {
      url = "https://drone-1.prima.it";
      opts = work;
    };
    "elm-search" = {
      url = "https://klaftertief.github.io/elm-search/";
      opts = personal ++ no_plugins;
    };
    "facebook" = {
      url = "https://www.facebook.com";
      opts = personal;
    };
    "github".url = "https://github.com";
    "gmail".url = "https://mail.google.com";
    "hackernews" = {
      url = "https://hckrnews.com/";
      opts = personal;
    };
    "instagram" = {
      url = "https://instagram.com";
      opts = personal;
    };
    "keep" = {
      url = "https://keep.google.com";
      opts = personal;
    };
    "maps" = {
      url = "https://www.google.it/maps/preview";
      opts = personal ++ no_plugins;
    };
    "meet" = {
      url = "https://meet.google.com";
      opts = work;
    };
    "messages" = {
      url = "https://messages.google.com/web/conversations";
      opts = personal ++ no_plugins;
    };
    "miro" = {
      url = "https://miro.com/app/dashboard";
      opts = work;
    };
    "n2f" = {
      url = "https://www.n2f.com/app/#";
      opts = work;
    };
    "netflix" = {
      url = "https://www.netflix.com";
      opts = personal;
    };
    "news" = {
      url = "https://news.google.it";
      opts = personal;
    };
    "nibol" = {
      url = "https://app.nibol.co";
      opts = work;
    };
    "nix-search" = {
      url = "https://search.nixos.org/packages";
      opts = personal;
    };
    "notion" = {
      url = "https://www.notion.so";
      opts = work;
    };
    "onepassword" = {
      url = "https://prima.1password.eu/home";
      opts = work;
    };
    "onshape" = {
      url = "https://cad.onshape.com";
      opts = personal ++ no_plugins;
    };
    "paint" = {
      url = "https://jspaint.app/";
      opts = [ "" ];
    };
    "personio" = {
      url = "https://prima-assicurazioni.personio.de";
      opts = work;
    };
    "photos" = {
      url = "https://photos.google.com";
      opts = personal;
    };
    "primevideo" = {
      url = "https://www.primevideo.com";
      opts = personal;
    };
    "printables" = {
      url = "https://www.printables.com";
      opts = personal;
    };
    "pyxis-doc" = {
      url = "http://elm.prima.design";
      opts = work;
    };
    "reddit" = {
      url = "https://reddit.com";
      opts = personal;
    };
    "sheets".url = "https://docs.google.com/spreadsheets";
    "slack" = {
      url = "https://prima.slack.com";
      opts = work;
    };
    "swarmia" = {
      url =
        "https://app.swarmia.com/insights/code/overview?timeframe=last_7_days";
      opts = work;
    };
    "telegram" = {
      url = "https://web.telegram.org/k/";
      opts = personal ++ no_plugins;
    };
    "trello" = {
      url = "https://www.trello.com";
      opts = personal;
    };
    "tvshowtime" = {
      url = "https://app.tvtime.com/shows/watchlist";
      opts = personal;
    };
    "wallet" = {
      url = "https://web.budgetbakers.com/dashboard";
      opts = personal ++ no_plugins;
    };
    "whatsapp" = {
      url = "https://web.whatsapp.com/";
      opts = personal ++ no_plugins;
    };
    "wellfare" = {
      url = "https://prima.oneflex.aon.it/flexible-benefits";
      opts = work;
    };
    "xbox" = {
      url = "https://xbox.com/play";
      opts = personal ++ no_plugins;
    };
    "backlog" = {
      url =
        "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issues/INTEXN?q=State:%20{No%20State%7d";
      opts = work;
    };
    "youtrack" = {
      url = "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/agiles";
      opts = work;
    };
    "youtube" = {
      url = "https://youtube.com";
      opts = personal;
    };
  };

  mkChromeApp = name:
    { url, opts ? [ ] }:
    let
      spacedOpts = lib.strings.concatStringsSep " " opts;
      chrome = "${pkgs.google-chrome}/bin/google-chrome-stable";
      chromeCall = ''
        ${chrome} --app='${url}' --new-window ${spacedOpts}
      '';
    in {
      name = ".local/bin/${name}";
      value = {
        text = ''
          #!/usr/bin/env bash

          ${chromeCall}
        '';
        executable = true;
      };
    };
in { home.file = lib.attrsets.mapAttrs' mkChromeApp apps; }
