{ config, pkgs, lib, ... }:
with lib;
{
  nixpkgs.config.allowUnfree = true;
  boot.cleanTmpDir = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.challengeResponseAuthentication = false;

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "d5e5fb6537bf9c06" ];

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuhpzDHBPvn8nv8RH1MRomDOaXyP4GziQm7r3MZ1Syk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+N7Tv2bGJDmwzl/81VB41PV0GtDn3NiExeHtWlsh+9 philipp@mordor"
  ];
    
  environment.systemPackages = with pkgs; [
    vim htop wget curl
    clinfo
  ];

  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];

  boot.initrd.availableKernelModules = [ "uas" ];
  boot.loader.timeout = mkForce 3;
  boot.kernelParams = [ "boot.shell_on_fail" "amd_iommu=pt" "ivrs_ioapic[32]=00:14.0" "iommu=soft" ];
  system.build.raw.diskSize = 4096;
  
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.enable = true;
  hardware.opengl.enable = true;                                                                                                                                                                                   
  hardware.opengl.driSupport = true;
  hardware.enableRedistributableFirmware = true;
}
