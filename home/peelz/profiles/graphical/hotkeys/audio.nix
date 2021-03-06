
{ lib, config, pkgs, ... }:

with lib;
{
  config = mkIf config.my.graphical.enable {
    dconf.enable = true;
    dconf.settings."com/peelz/audio" = {
      headset_sink = "alsa_output.usb-Kingston_HyperX_Cloud_Flight_Wireless_Headset-00.iec958-stereo";
      mic_source = "alsa_input.usb-Focusrite_Scarlett_Solo_USB-00.iec958-stereo";
      headset_mic_source = "alsa_input.usb-Kingston_HyperX_Cloud_Flight_Wireless_Headset-00.mono-fallback";
      notification_volume = 30000;
      # control id for 'PCM Playback Volume'
      volume_control_id = 6;
    };

    my.graphical.services.sxhkd = mkIf config.my.graphical.enable {
      hotkeys = let
        grep = "${pkgs.gnugrep}/bin/grep";
        sed = "${pkgs.gnused}/bin/sed";
        dconf = "${pkgs.dconf}/bin/dconf";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        paplay = "${pkgs.pulseaudio}/bin/paplay";
        paprop = "${pkgs.paprop}/bin/paprop";
        amixer = "${pkgs.alsaUtils}/bin/amixer";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
      in [
        # Volume control
        {
          hotkey = "{XF86AudioLowerVolume,XF86AudioRaiseVolume}";
          cmd = ''
            sink="$(${dconf} read /com/peelz/audio/headset_sink | ${sed} -e "s/^'//" -e "s/'$//")"
            # control the volume through
            ${pactl} set-sink-volume "$sink" {-,+}5%
            id="$(${paprop} get-prop sink "$sink" alsa.card)"
            # fight with the ALSA driver to enforce a constant volume
            control_id="$(${dconf} read /com/peelz/audio/volume_control_id)"
            ${amixer} -c "$id" cset numid="$control_id" 49
            ${amixer} -c "$id" cset numid="$control_id" 50
          '';
        }

        # Mute headset
        {
          hotkey = "XF86AudioMute";
          cmd = ''
            sink="$(${dconf} read /com/peelz/audio/headset_sink)"
            ${pactl} set-sink-mute "$sink" toggle
          '';
        }

        # Play/pause through MPRIS
        {
          hotkey = "XF86Audio{Stop,Prev,Play,Next}";
          cmd = "${playerctl} -i vlc {stop,previous,play-pause,next}";
        }

        # Mute microphone
        {
          hotkey = "{hyper + m,button8}";
          cmd = ''
            sink="$(${dconf} read /com/peelz/audio/headset_sink | ${sed} -e "s/^'//" -e "s/'$//")"
            src="$(${dconf} read /com/peelz/audio/mic_source | ${sed} -e "s/^'//" -e "s/'$//")"
            volume="$(${dconf} read /com/peelz/audio/notification_volume)"
            is_muted="$(${paprop} is-muted source "$src")"
            if [[ "$is_muted" == "1" ]]; then
              ${pactl} set-source-mute "$src" false
              ${paplay} ${./mic_activated.wav} \
                --device "$sink" \
                --volume "$volume" &
              echo 'Microphone unmuted'
            else
              ${pactl} set-source-mute "$src" true
              ${paplay} ${./mic_muted.wav} \
                --device "$sink" \
                --volume "$volume" &
              echo 'Microphone muted'
            fi
          '';
        }

        # Unmap 2nd mouse button
        {
          hotkey = "button9";
          cmd = ":";
        }
      ];
    };
  };
}
