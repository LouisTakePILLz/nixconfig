{ lib, config, pkgs, ... }:

with lib;
let
  notNullOrEmpty = s: !(s == null || s == "");
  cfg = config.my.graphical.services.sxhkd;
  hotkeySubmodule = types.submodule {
    options = {
      hotkey = mkOption {
        type = types.str;
      };
      cmd = mkOption {
        type = types.oneOf (with types; [ str package ]);
      };
    };
  };
in {
  options.my.graphical.services.sxhkd = {
    enable = mkEnableOption "X hotkey daemon";
    envVars = lib.mkOption {
      type = types.attrs;
      internal = true;
      default = {};
      description = ''
        Environment variables passed to sxhkd and its config.
      '';
    };
    hotkeys = lib.mkOption {
      type = types.listOf hotkeySubmodule;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ sxhkd ];

    systemd.user.services.sxhkd = let
      sxhkdrc = pkgs.writeText "sxhkdrc" (let
        formatBinding = binding:
          let
            cmd = if builtins.isString binding.cmd && stringLength binding.cmd >= 512
              then pkgs.writeShellScript "shxkd-hotkey-cmd" binding.cmd
              else binding.cmd;
          in "${binding.hotkey}\n  ${cmd}";
        hotkeys = concatStringsSep "\n\n"
          (map formatBinding cfg.hotkeys);
      in hotkeys);
    in {
      Unit = {
        Description = "X hotkey daemon";
        PartOf = [ "graphical-session.target" ];
        X-RestartIfChanged = true;
      };

      Service = {
        Environment = lib.attrValues (lib.mapAttrs
          (k: v: "${k}=${escapeShellArg v}")
          (cfg.envVars // {
            PATH =
              (lib.optionalString
                (cfg.envVars ? PATH
                  && cfg.envVars.PATH != null
                  && cfg.envVars.PATH != "")
                "${cfg.envVars.PATH}:")
              + (lib.makeBinPath (with pkgs; [
                # required for sxhkd to execute commands
                bash
              ]));
            SXHKD_SHELL = "bash";
          }));
        ExecStart = "${pkgs.sxhkd}/bin/sxhkd -m -1 -c ${sxhkdrc}";
        Restart = "on-failure";
      };
    };
  };
}