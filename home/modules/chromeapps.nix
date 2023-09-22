{ lib, ... }:
let
  personal = [ "--profile-directory='Default'" ];
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
    "codescene".url =
      "https://codescene.io/projects/35921/jobs/978159/results/code/hotspots/system-map";
    "coggle".url = "https://coggle.it";
    "coronavisual".url = "https://blkgoose.github.io/coronavisual";
    "crunchyroll" = {
      url = "https://www.crunchyroll.com/it";
      opts = personal ++ no_plugins;
    };
    "datadog".url = "https://app.datadoghq.eu/";
    "disney" = {
      url = "https://disneyplus.com";
      opts = personal;
    };
    "drone_ci".url = "https://drone-1.prima.it";
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
    "instagram" = {
      url = "https://instagram.com";
      opts = personal;
    };
    "keep" = {
      url = "https://keep.google.com";
      opts = personal;
    };
    "kibana".url = "https://kibana-k8s.prima.it/app/discover#";
    "maps" = {
      url = "https://www.google.it/maps/preview";
      opts = personal ++ no_plugins;
    };
    "meet".url = "https://meet.google.com";
    "messages" = {
      url = "https://messages.google.com/web/conversations";
      opts = personal ++ no_plugins;
    };
    "miro".url = "https://miro.com/app/dashboard";
    "n2f".url = "https://www.n2f.com/app/#";
    "netflix" = {
      url = "https://www.netflix.com";
      opts = personal;
    };
    "news" = {
      url = "https://news.google.it";
      opts = personal;
    };
    "nibol".url = "https://app.nibol.co";
    "notion".url = "https://www.notion.so";
    "onshape" = {
      url = "https://cad.onshape.com";
      opts = personal ++ no_plugins;
    };
    "paint" = {
      url = "https://jspaint.app/";
      opts = [ "" ];
    };
    "personio".url = "https://prima-assicurazioni.personio.de";
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
    "pyxis-doc".url = "http://elm.prima.design";
    "reddit" = {
      url = "https://reddit.com";
      opts = personal;
    };
    "sheets".url = "https://docs.google.com/spreadsheets";
    "slack".url = "https://prima.slack.com";
    "swarmia" = {
      url = "https://app.swarmia.com/insights";
      opts = [ "" ];
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
      url = "https://www.tvtime.com/en/to-watch";
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
    "xbox" = {
      url = "https://xbox.com/play";
      opts = personal ++ no_plugins;
    };
    "youtrack-backlog".url =
      "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/search/Team%20Intermediaries%20Experience%20(INTEXN)%20Backlog-967";
    "youtrack".url =
      "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/agiles";
    "youtube" = {
      url = "https://youtube.com";
      opts = personal;
    };
  };

  mkChromeApp = name:
    { url, opts ? [ ] }:
    let
      spacedOpts = lib.strings.concatStringsSep " " opts;
      chrome = "google-chrome-stable";
      chromeCall = ''
        ${chrome} --app='${url}' --new-window ${spacedOpts}
      '';
    in {
      name = ".local/bin/${name}";
      value = {
        text = ''
          #!/usr/bin/env bash
        '' + chromeCall;
        executable = true;
      };
    };
in { home.file = lib.attrsets.mapAttrs' mkChromeApp apps; }
