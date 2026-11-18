# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  hardware.amdgpu.opencl.enable = true;
  nixpkgs.config.rocmSupport = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "masamune"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 1920x1080 --rate 240
  '';

  services.xserver.displayManager.lightdm = {
    enable = true;

    # Setting the greeter
    greeters.gtk.enable = true;

    # Example of the default image background (must be an absolute path
    #background = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;

  };
  services.xserver.windowManager.windowmaker.enable = true;
  services.xserver.displayManager.defaultSession = "none+windowmaker";  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sphere = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" "rtkit" "pipewire" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = "/etc/passwdhash";
    packages = with pkgs; [
      tree
    ];
  };

  

  #  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    unzip
    alacritty
    pkgs.windowmaker
    pkgs.vivaldi
    pkgs.vivaldi-ffmpeg-codecs
    pkgs.ffmpeg
    pkgs.neovim
    pkgs.kdePackages.kdenlive
    pkgs.pavucontrol
    pkgs.bluetuith
    pkgs.zoom-us
    pkgs.git
    # Optional: Games
    pkgs.steam
    pkgs.heroic
    pkgs.razergenie
    pkgs.prismlauncher

    # 1. System Status (CPU, Memory, Swap, Uptime)
    windowmaker.passthru.dockapps.cputnik   # Clean CPU + RAM usage graph

    # 2. Clock & Calendar
    windowmaker.passthru.dockapps.wmCalClock # Anti-aliased clock with calendar display

    # 4. Internet / Network Traffic
    networkmanagerapplet
    pasystray
    windowmaker.passthru.dockapps.wmsystemtray

    rocmPackages.clr.icd
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    clinfo

    distrobox
  ];

  environment.variables = {
    # Restrict ROCm and HIP to Device 0 (RX 9060 XT) and hide the iGPU
    ROCR_VISIBLE_DEVICES = "0";
    HIP_VISIBLE_DEVICES = "0";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      xorg.fontmiscmisc
      xorg.fontalias
    ];
  };

  systemd.tmpfiles.rules = 
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];


  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
      libGL
      glib
      rocmPackages.clr
      rocmPackages.rocblas
      rocmPackages.hipblas
      rocmPackages.miopen
    ];
  };

  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

