{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.dx5 = import ./home.nix;
    backupFileExtension = "backup";
  };

  # ---------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 5;
    };
    kernelParams = [ "quiet" "splash"  ];
    consoleLogLevel = 0;
    plymouth.enable = true;
  };


  # ---------------------------------------------------------

  security.apparmor = {
    enable = true;
  };


  # Kernel'in bellek adreslerini gizler (Exploit koruması)
  boot.kernel.sysctl = {
    # Kernel loglarını (dmesg) normal kullanıcıdan gizle (Gizlilik)
    "kernel.dmesg_restrict" = 1;
    
    # Kernel pointerlarını gizle (Exploit zorlaştırma)
    # Eğer sistem izleme araçlarında hata alırsan bunu 1 yap veya sil.
    "kernel.kptr_restrict" = 2; 
    
    # Alt ağ saldırılarını (ICMP Redirect) engelle
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
  };



  # ---------------------------------------------------------
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver    
        libvdpau-va-gl       
        intel-compute-runtime 
      ];
    };
    cpu.intel.updateMicrocode = true;
  };

  
  services.thermald.enable = true;
  
  zramSwap.enable = true;
  
  services.fstrim.enable = true;


  # ---------------------------------------------------------
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "trq";

  # ---------------------------------------------------------
  users.users.dx5 = {
    isNormalUser = true;
    description = "dx5";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ]; # 'input' libinput için iyidir
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------
  
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; 
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # ---------------------------------------------------------
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  security.polkit.enable = true;

  programs.zsh.enable = true;
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  # ---------------------------------------------------------
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    pciutils
    btop
    lm_sensors
    polkit_gnome 
    pamixer 
    brightnessctl
  ];

  system.stateVersion = "25.11";
}
