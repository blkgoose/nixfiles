{ lib, pkgs, config, ... }:
let
  personal = [ "--profile-directory='Default'" ];
  work = [ "--profile-directory='Profile 1'" ];
  unsafe = [
    "--disable-web-security --user-data-dir=${config.xdg.configHome}/unsafe-chrome"
  ];
  no_plugins = [ "--disable-extensions" "--disable-plugins" ];

  chromeWrapper = opts: url:
    let
      chrome = with pkgs; "${(nixGL google-chrome)}/bin/google-chrome-stable";
      spacedOpts = lib.strings.concatStringsSep " " opts;
    in ''
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
    "chatGPT" = {
      url = "https://chatgpt.com/";
      wrapper = chromeWrapper personal;
    };
    "chess".url = "https://www.chess.com";
    "codescene" = {
      url =
        "https://codescene.io/projects/35921/jobs/978159/results/code/hotspots/system-map";
      wrapper = chromeWrapper work;
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
    "dashboard-sec" = {
      url =
        "https://security-metrics.helloprima.com/vm/projects/INT%20-%20Intermediaries%20Experience%20&%20Network%20Management.html";
      wrapper = chromeWrapper work;
    };
    "disney" = {
      url = "https://disneyplus.com";
      wrapper = chromeWrapper personal;
    };
    "drone_ci" = {
      url = "https://drone-1.prima.it";
      wrapper = chromeWrapper work;
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
      wrapper = chromeWrapper work;
    };
    "gmail".url = "https://mail.google.com";
    "hackernews" = {
      url = "https://hckrnews.com/";
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
    "meet" = {
      url = "https://meet.google.com";
      wrapper = chromeWrapper work;
    };
    "messages" = {
      url = "https://messages.google.com/web/conversations";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "miro" = {
      url = "https://miro.com/app/dashboard";
      wrapper = chromeWrapper work;
    };
    "n2f" = {
      url = "https://www.n2f.com/app/#";
      wrapper = chromeWrapper work;
    };
    "netflix" = {
      url = "https://www.netflix.com";
      wrapper = chromeWrapper personal;
    };
    "news" = {
      url = "https://news.google.it";
      wrapper = chromeWrapper personal;
    };
    "nibol" = {
      url = "https://app.nibol.co";
      wrapper = chromeWrapper work;
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
    "notion" = {
      url = "https://www.notion.so";
      wrapper = chromeWrapper work;
    };
    "onepassword" = {
      url = "https://prima.1password.eu/home";
      wrapper = chromeWrapper work;
    };
    "onshape" = {
      url = "https://cad.onshape.com";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "paint" = { url = "https://jspaint.app/"; };
    "personio" = {
      url = "https://prima-assicurazioni.personio.de";
      wrapper = chromeWrapper work;
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
    "pyxis-doc" = {
      url = "http://elm.prima.design";
      wrapper = chromeWrapper work;
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
    "slack" = {
      url = "https://app.slack.com/client/T024WK3NT/C04KE5JMKFG";
      wrapper = chromeWrapper work;
    };
    "swarmia" = {
      url =
        "https://app.swarmia.com/insights/code/overview?timeframe=last_7_days";
      wrapper = chromeWrapper work;
    };
    "telegram" = {
      url = "https://web.telegram.org/k/";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "trello" = {
      url = "https://www.trello.com";
      wrapper = chromeWrapper personal;
    };
    "tvshowtime" = {
      url = "https://app.tvtime.com/shows/watchlist";
      wrapper = chromeWrapper personal;
    };
    "udemy" = {
      url = "https://prima.udemy.com/organization/home/";
      wrapper = chromeWrapper work;
    };
    "wallet" = {
      url = "https://web.budgetbakers.com/dashboard";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "whatsapp" = {
      url = "https://web.whatsapp.com/";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "wellfare" = {
      url = "https://prima.oneflex.aon.it/flexible-benefits";
      wrapper = chromeWrapper work;
    };
    "xbox" = {
      url = "https://xbox.com/play";
      wrapper = chromeWrapper (personal ++ no_plugins);
    };
    "backlog" = {
      url =
        "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/issues/INTEXN?q=State:%20{No%20State%7d";
      wrapper = chromeWrapper work;
    };
    "youtrack" = {
      url = "https://prima-assicurazioni-spa.myjetbrains.com/youtrack/agiles";
      wrapper = chromeWrapper work;
    };
    "youtube" = {
      url = "https://youtube.com";
      wrapper = chromeWrapper personal;
    };
  };

  mkWrappedApp = name:
    { url, wrapper ? chromeWrapper [ ] }: {
      name = ".local/bin/${name}";
      value = {
        text = ''
          #!/usr/bin/env bash

          ${(wrapper url)}
        '';
        executable = true;
      };
    };
in { home.file = lib.attrsets.mapAttrs' mkWrappedApp apps; }
