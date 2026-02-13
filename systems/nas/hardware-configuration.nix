{ pkgs, config, lib, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3e85357b-c919-4a96-947e-004bdeb99415";
    fsType = "ext4";
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/47F4-25B3";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "mnt/data" = {
      device = "/dev/disk/by-uuid/aab2362b-6171-4012-a2c8-76d64cbfb2e6";
      fsType = "btrfs";
      options = [ "defaults" "compress=zstd" "autodefrag" "nofail" ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/b0d30cfd-68f4-4b2c-b1c4-c300e267eba0"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };
}
