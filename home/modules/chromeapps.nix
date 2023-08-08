{ lib, ... }:
let
  apps = {
    "amazon" = {
      url = "https://amazon.it";
      opts = [ "--profile-directory='Default'" ];
    };
    "books" = {
      url = "https://play.google.com/books";
      opts = [ "--profile-directory='Default'" ];
    };
    "calendar" = { url = "https://calendar.google.com/calendar"; };
    "chess" = { url = "https://www.chess.com"; };
    "codescene" = {
      url =
        "https://codescene.io/projects/35921/jobs/978159/results/code/hotspots/system-map";
    };
    "coggle" = { url = "https://coggle.it"; };
    "coronavisual" = { url = "https://blkgoose.github.io/coronavisual"; };
    "crunchyroll" = {
      url = "https://www.crunchyroll.com/it";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "datadog" = { url = "https://app.datadoghq.eu/"; };
    "disney" = {
      url = "https://disneyplus.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "drone_ci" = { url = "https://drone-1.prima.it"; };
    "elm-search" = {
      url = "https://klaftertief.github.io/elm-search/";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "facebook" = {
      url = "https://www.facebook.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "github" = { url = "https://github.com"; };
    "gmail" = { url = "https://mail.google.com"; };
    "instagram" = {
      url = "https://instagram.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "keep" = {
      url = "https://keep.google.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "kibana" = { url = "https://kibana-k8s.prima.it/app/discover#"; };
    "maps" = {
      url = "https://www.google.it/maps/preview";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "meet" = { url = "https://meet.google.com"; };
    "messages" = {
      url = "https://messages.google.com/web/conversations";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "miro" = { url = "https://miro.com/app/dashboard"; };
    "n2f" = { url = "https://www.n2f.com/app/#"; };
    "netflix" = {
      url = "https://www.netflix.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "news" = {
      url = "https://news.google.it";
      opts = [ "--profile-directory='Default'" ];
    };
    "nibol" = { url = "https://app.nibol.co"; };
    "notion" = { url = "https://www.notion.so"; };
    "onshape" = {
      url = "https://cad.onshape.com";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "paint" = {
      url = "https://jspaint.app/";
      opts = [ "" ];
    };
    "personio" = { url = "https://prima-assicurazioni.personio.de"; };
    "photos" = {
      url = "https://photos.google.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "primevideo" = {
      url = "https://www.primevideo.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "printables" = {
      url = "https://www.printables.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "pyxis-doc" = { url = "http://elm.prima.design"; };
    "reddit" = {
      url = "https://reddit.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "sheets" = { url = "https://docs.google.com/spreadsheets"; };
    "slack" = { url = "https://prima.slack.com"; };
    "stadia" = {
      url = "https://stadia.google.com";
      opts = [ "--disable-extensions" "--disable-plugins" ];
    };
    "swarmia" = {
      url = "https://app.swarmia.com/insights";
      opts = [ "" ];
    };
    "trello" = {
      url = "https://www.trello.com";
      opts = [ "--profile-directory='Default'" ];
    };
    "tvshowtime" = {
      url = "https://www.tvtime.com/en/to-watch";
      opts = [ "--profile-directory='Default'" ];
    };
    "wallet" = {
      url = "https://web.budgetbakers.com/dashboard";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "xbox" = {
      url = "https://xbox.com/play";
      opts = [
        "--disable-extensions"
        "--disable-plugins"
        "--profile-directory='Default'"
      ];
    };
    "youtrack-backlog" = {
      url =
        "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/search/Team%20Intermediaries%20Experience%20(CMAEN)%20Backlog-967";
    };
    "youtrack" = {
      url = "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/agiles";
    };
    "youtube" = {
      url = "https://youtube.com";
      opts = [ "--profile-directory='Default'" ];
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
      name = ".local/bin/user/${name}";
      value = {
        text = ''
          #!/usr/bin/env bash
        '' + chromeCall;
        executable = true;
      };
    };
in { home.file = lib.attrsets.mapAttrs' mkChromeApp apps; }
