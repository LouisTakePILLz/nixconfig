{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.my.gaming;
in {
  options.my.gaming = {
    enable = mkEnableOption "Gaming programs";
    ultrawide = mkEnableOption "21:9-specific settings";
  };

  config = mkIf cfg.enable {
    home.packages = let
      steam = (pkgs.steam.override (self: {
        extraLibraries = pkgs: with pkgs; [
          # Stardew Valley mods require GDI+
          libgdiplus
        ];
      }));
    in with pkgs; [
      lutris
      steam
      steam.run
      protontricks
      multimc
    ];

    my.graphical.wm.bspwm.rules = (optional cfg.ultrawide
    # Force Overwatch (in a Wine virtual desktop) to a 16:9 resolution
    # This is used to fix the aim drifting issue with non-16:9 resolutions
    { name = "Wine:explorer.exe";
      state = "floating";
      center = "on";
      border = "off";
      rectangle = {
        width = 2560;
        height = 1440;
      };
    }) ++ [
      # Fix Overcooked 2 being aligned on the left side of the screen
      { name = "Overcooked2.x86_64";
        center = "on";
      }
      { name = "Steam";
        follow = "off";
        desktop = 8;
      }
    ];
  };
}
