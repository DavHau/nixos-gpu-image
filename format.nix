{ config, pkgs, lib, modulesPath, ... }: let

  clever-tests = builtins.fetchGit {
    url = https://github.com/cleverca22/nix-tests;
    rev = "5ace3327599c7121ac517f30ac291e948158fd3a"; #master on 2018-05-20
  };
in {
  imports = [
    "${toString modulesPath}/installer/netboot/netboot-minimal.nix"
    "${clever-tests}/kexec/autoreboot.nix"
    "${clever-tests}/kexec/kexec.nix"
    "${clever-tests}/kexec/justdoit.nix"
  ];

  system.build = rec {
    kexec_tarball = pkgs.callPackage "${toString modulesPath}/../lib/make-system-tarball.nix" {
      storeContents = [
        { object = config.system.build.kexec_script; symlink = "/kexec_nixos"; }
      ];
      contents = [];
    };

    kexec_tarball_self_extract_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
        #!/bin/sh
        set -eu
        ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ { print NR + 1; exit 0; }' $0`
        tail -n+$ARCHIVE $0 | tar xJ -C /
        /kexec_nixos
        exit 1
        __ARCHIVE_BELOW__
      '';
    };

    kexec_bundle = pkgs.runCommand "kexec_bundle" {} ''
      cat \
        ${kexec_tarball_self_extract_script} \
        ${kexec_tarball}/tarball/nixos-system-${kexec_tarball.system}.tar.xz \
        > $out
      chmod +x $out
    '';
  };

  boot.loader.grub.enable = false;
  boot.kernelParams = [
    "console=ttyS0,115200"          # allows certain forms of remote access, if the hardware is setup right
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  networking.hostName = lib.mkDefault "kexec";

  formatAttr = "kexec_tarball";
  filename = "*/tarball/*.tar.xz";
}