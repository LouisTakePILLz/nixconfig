{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.my.graphical;
in {
  imports = [
    ./nvidia.nix
    ./hotkeys
    ../../../modules/graphical/xorg.nix
    ../../../modules/graphical/bspwm.nix
    ../../../modules/graphical/sxhkd.nix
  ];

  options.my.graphical = {
    enable = mkEnableOption "Graphical environment";
  };

  config = mkIf cfg.enable {
    my.graphical.xorg = {
      autorepeat = {
        delay = 300;
        rate = 50;
      };
      screensaver = {
        enable = true;
        delay = 300;
        dpms = false;
      };
    };

    my.graphical.wm.bspwm = {
      enable = true;
      window_gap = 12;
      block_fullscreen = true;
      border_width = 4;
      colors = {
        normal = "#30302f";
        active = "#9e8e7e";
        focused = "#906ef5";
      };
    };

    # Packages
    home.packages = (with pkgs.pkgs-unstable; [
      # Bleeding edge packages
      kitty
    ]) ++ (with pkgs; [
      # Desktop environment
      polybar
      rofi
      playerctl
      xclip
      xdg_utils
      xorg.xmodmap
      xorg.xwininfo
      xdotool

      # Programs
      cool-retro-term
      (chromium.override (old: {
        # Enable the VA-API patch for hardware-accelerated video decoding
        enableVaapi = true;
        # This is a workaround for the prefers-color-scheme CSS bug until
        # https://bugs.chromium.org/p/chromium/issues/detail?id=998903 is fixed
        commandLineArgs = "--force-dark-mode --enable-features=WebUIDarkMode";
      }))
      firefox
      pavucontrol
      gimp
      inkscape
      vlc
      qbittorrent
      virtmanager
      libreoffice
      obs-studio
      shutter spectacle peek
      screenkey
      qdirstat
      remmina
      bless

      # Gnome utilities
      gnome3.gnome-calendar
      gnome3.gnome-calculator
      gnome3.nautilus
      gnome3.gnome-system-monitor
      gnome3.file-roller
      gnome3.dconf-editor

      # Fonts
      (nerdfonts.override (old: {
        fonts = [ "SourceCodePro" ];
      }))
    ]);

    my.graphical.wm.bspwm.rules = [{
      name = "Peek";
      state = "floating";
    }];

    # Enable fontconfig (required for generating ~/.cache/fontconfig)
    # 19.09: mkForce avoids an option conflict; https://github.com/rycee/home-manager/issues/1118
    fonts.fontconfig.enable = mkForce true;

    # Set GTK and Qt theme
    gtk = {
      enable = true;
      theme = mkDefault {
        package = pkgs.arc-theme;
        name = "Arc-Dark";
      };
      iconTheme = mkDefault {
        package = pkgs.arc-icon-theme;
        name = "Arc";
      };
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    # Set cursor
    xsession.pointerCursor = mkDefault {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
    };

    # Set default programs
    xdg.mimeApps.enable = true;
    xdg.mimeApps.defaultApplications = let
      file_browser = [ "org.gnome.Nautilus.desktop" ];
      web_browser = [ "chromium-browser.desktop" ];
      torrent = [ "qbittorrent.desktop" ];
    in {
      "inode/directory" = file_browser;
      "text/html" = web_browser;
      "x-scheme-handler/http" = web_browser;
      "x-scheme-handler/https" = web_browser;
      "x-scheme-handler/about" = web_browser;
      "x-scheme-handler/unknown" = web_browser;
      "application/x-bittorrent" = torrent;
      "x-scheme-handler/magnet" = torrent;
    };

    # OBS Plugins
    xdg.configFile."obs-studio/plugins/v4l2sink".source =
      "${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink";

    # Set default browser
    pam.sessionVariables.BROWSER = "chromium";

    # Set default terminal
    pam.sessionVariables.TERMINAL = "kitty";

    # Use the Canadian Multilingual Standard layout
    home.keyboard.layout = "ca(multi)";

    # Map caps to hyper
    home.keyboard.options = [ "caps:hyper" ];

    # Enable Redshift for night time
    services.redshift = {
      enable = true;
      provider = "manual";
      latitude = "45.50";
      longitude = "-73.57";
      temperature.day = 6500;
      temperature.night = 3200;
    };
  };
}
