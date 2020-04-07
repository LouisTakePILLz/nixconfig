# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  # Hardware
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Kernel modules
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" "r8125" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    r8125
  ];

  # Root (LVM partition)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/39070d14-7ea0-4d63-bb68-cca32d3dc0f4";
    fsType = "ext4";
  };

  # EFI Boot loader
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CF0D-9EA1";
    fsType = "vfat";
  };

  # Other LVM partitions
  fileSystems."/mnt/steam" = {
    device = "/dev/disk/by-uuid/1e20e85c-b692-411f-aab5-66c19ecb2bf5";
    fsType = "ext4";
  };
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/9df014e5-955d-4e3a-92b1-7750a4cd3ebc";
    fsType = "ext4";
  };

  # Old NTFS volumes
  fileSystems."/mnt/echo" = {
    device = "/dev/disk/by-uuid/56362696362676E1";
    fsType = "ntfs-3g";
  };
  fileSystems."/mnt/charlie" = {
    device = "/dev/disk/by-uuid/6EC886EBC886B0BF";
    fsType = "ntfs-3g";
  };
  fileSystems."/mnt/delta" = {
    device = "/dev/disk/by-uuid/BC4080AD40807046";
    fsType = "ntfs-3g";
  };
  fileSystems."/mnt/hotel" = {
    device = "/dev/disk/by-uuid/06804D92804D895F";
    fsType = "ntfs-3g";
  };

  # PS3 controller
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
  '';

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 24;
}
