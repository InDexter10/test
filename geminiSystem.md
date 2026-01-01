❯ fastfetch
          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             dx5@nixos
          ▜███▙       ▜███▙  ▟███▛             ---------
           ▜███▙       ▜███▙▟███▛              OS: NixOS 25.11 (Xantusia) x86_64
            ▜███▙       ▜██████▛               Host: Gemini Lake Pro PRO20EX 8GL (MS-AAC2) (1.0)
     ▟█████████████████▙ ▜████▛     ▟▙         Kernel: Linux 6.12.63
    ▟███████████████████▙ ▜███▙    ▟██▙        Uptime: 11 mins
           ▄▄▄▄▖           ▜███▙  ▟███▛        Packages: 1187 (nix-system), 931 (nix-user), 14 (flatpak)
          ▟███▛             ▜██▛ ▟███▛         Shell: zsh 5.9
         ▟███▛               ▜▛ ▟███▛          Display (AIO PC): 1600x900 in 19", 60 Hz [Built-in]
▟███████████▛                  ▟██████████▙    WM: niri (Wayland)
▜██████████▛                  ▟███████████▛    Theme: Adwaita-dark [GTK2/3/4]
      ▟███▛ ▟▙               ▟███▛             Icons: Papirus-Dark [GTK2/3/4]
     ▟███▛ ▟██▙             ▟███▛              Cursor: Bibata-Modern-Classic
    ▟███▛  ▜███▙           ▝▀▀▀▀               Terminal: alacritty 0.16.1
    ▜██▛    ▜███▙ ▜██████████████████▛         Terminal Font: JetBrainsMono Nerd Font (11.0pt)
     ▜▛     ▟████▙ ▜████████████████▛          CPU: Intel(R) Celeron(R) N4000 (2) @ 2.60 GHz
           ▟██████▙       ▜███▙                GPU: Intel UHD Graphics 600 @ 0.65 GHz [Integrated]
          ▟███▛▜███▙       ▜███▙               Memory: 823.06 MiB / 7.56 GiB (11%)
         ▟███▛  ▜███▙       ▜███▙              Swap: 0 B / 3.78 GiB (0%)
         ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘              Disk (/): 20.56 GiB / 232.69 GiB (9%) - ext4
                                               Local IP (wlo1): 192.168.43.198/24
                                               Locale: en_US.UTF-8


❯ cat configuration.nix
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
  };


  # ---------------------------------------------------------

  security.apparmor.enable = true;

  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
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

    # --- EKLEME: GÜVENLİK DUVARI ---
    firewall = {
      enable = true;
      allowedTCPPorts = [];
    };

    #  Quad9
    nameservers = [ "9.9.9.9" "149.112.112.112" ];
  };

  # DNS isteklerini şifrelemek için (systemd-resolved kullanımı)
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" ];
    dnsovertls = "true";
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
  programs.niri.enable = true;

xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true; # XDG-Open komutunu portala yönlendir

    # Gereksiz paket karmaşasını önlemek için sadece GTK yüklüyoruz
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome # Bazen ayarlar (dark mode) için bu da gerekebilir, kalsın.
    ];

    # BURASI KRİTİK: Niri (ve diğerleri) için varsayılanı zorla
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gtk" ];
      };
    };
  };



security.polkit.enable = true;
programs.zsh.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };



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
  # ---------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    pciutils
    lm_sensors
  ];


  #----------------------------------------------------------

  system.stateVersion = "25.11";
}
/etc/nixos🔒
❯ cat home.nix
{ config, pkgs, lib, ... }:

{
imports = [
    ./modules/nvim.nix   # İşte burada dosyayı içeri alıyoruz
    ./modules/yazi.nix
    ./modules/firefox.nix
  ];

  # ---------------------------------------------------------
  home.username = "dx5";
  home.homeDirectory = "/home/dx5";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ---------------------------------------------------------
  # 2. TEMEL SİSTEM ARAÇLARI & BAĞIMLILIKLAR
  # ---------------------------------------------------------
  home.packages = with pkgs; [
    btop
    polkit_gnome
    pamixer
    brightnessctl
    zoxide
    imagemagick
    fastfetch
    tree
    # -- Grafik Arayüz Gereksinimleri --
    wl-clipboard # Panoya kopyalama (Alacritty/Neovim için şart)
    libnotify    # Bildirim gönderme aracı
    kdePackages.okular
    kdePackages.gwenview
    steam-run
    temurin-bin-11
    xfce.thunar
    xfce.thunar-archive-plugin
    timewarrior
    waybar

   # --- NİRİ ARAÇLARI
    swaylock
    swayidle
    wl-clipboard
    mako
    grim
    slurp
    swaybg # Eğer duvar kağıdı kullanacaksan
    xwayland-satellite # niri wm için
  ];



  #----------------------------------------------------------
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";  # İstediğin tema adı
    package = pkgs.bibata-cursors;
    size = 24;                   # Boyut (Çok önemli!)

    # Hem X11 (Alacritty/Firefox bazen buraya bakar)
    # Hem GTK (Brave/Files) için ayarları üret
    gtk.enable = true;
    x11.enable = true;
  };

  # 2. İnatçı uygulamalar için Ortam Değişkenleri
  home.sessionVariables = {
    # Wayland ve X11 uygulamalarına boyutu zorla
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Ice"; # Bazı modern appler buna bakar
    HYPRCURSOR_SIZE = "24";

    EDITOR = "nvim";
    VISUAL = "nvim";

    WINIT_UNIX_BACKEND = "wayland";


  };

  # ---------------------------------------------------------
  # 5. LAUNCHER (Fuzzel)
  # ---------------------------------------------------------
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.alacritty}/bin/alacritty";
        layer = "overlay";
        width = 40;
        font = "JetBrainsMono Nerd Font:size=11";
        line-height = 20;
        fields = "name,generic,comment,categories,filename,keywords";
        show-actions = true;
      };
      colors = {
        background = "1e1e2eff"; # Koyu tema (Catppuccin vari)
        text = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
      };
    };
  };

  # ---------------------------------------------------------

 # ---------------------------------------------------------
  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";
      window = {
        decorations = "none";
        opacity = 0.90;
        padding = { x = 5; y = 5; };
      };
      selection.save_to_clipboard = true;

      font = {
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        size = 11.0;
      };
    };
  };

 # ---------------------------------------------------------
  # 8. ZELLIJ (Basit & Etkili)
  # ---------------------------------------------------------
  programs.zellij = {
    enable = true;
  };

  # ---------------------------------------------------------
  # 10. SHELL (Zsh + Starship - Optimize Edilmiş)
  # ---------------------------------------------------------
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    initContent = ''
      eval "$(zoxide init zsh)"
    '';

    shellAliases = {
      l = "ls -la";
      c = "clear";
      nixconf = "sudo nvim /etc/nixos/configuration.nix";
      homeconf = "sudo nvim /etc/nixos/home.nix";
      swayconf = "sudo nvim /etc/nixos/sway.conf"; # Sway ayar dosyası
      sysup = "sudo nixos-rebuild switch";
    };
    history = {
      size = 5000; # Çok büyük history açılışı yavaşlatabilir
      share = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
      package.disabled = true; # Paket versiyonunu göstermek bazen yavaştır
    };
  };

  # ---------------------------------------------------------
  # 11. GÖRÜNÜM (GTK & Cursor)
  # ---------------------------------------------------------
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark"; # En stabil ve hafif koyu tema
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic"; # Şık ve modern
      package = pkgs.bibata-cursors;
    };
  };
}
/etc/nixos🔒
❯ cd modules
/etc/nixos/modules🔒
❯ cat nvim.nix
 { pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      gcc     # Treesitter için şart
      gnumake # Bazı pluginler ister
      unzip   # İndirmeler için
      ripgrep # Teleskope (arama) için şart
      fd      # Dosya bulucu
      fzf
      gzip

      lazygit
      nodejs_22
      tree-sitter
      typescript-language-server  # JS ve TS için
      vscode-langservers-extracted # HTML, CSS, JSON için
      lua-language-server         # Lua için
      tailwindcss-language-server
      nil
      nodePackages.prettier
      stylua
      biome
      emmet-ls
    ];
  };

}
/etc/nixos/modules🔒
❯ cat firefox.nix
{pkgs, ...}:
{
programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;

      EnableTrackingProtection = {
        Value = true;
        Locked = false; # KİLİDİ KALDIRIYORUZ! (Arkenfox yönetebilsin)
        Cryptomining = true;
        Fingerprinting = true; # Yazım düzeltildi (küçük 'p')
      };

      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://mozilla.cloudflare-dns.com/dns-query";
        Locked = false; # İstersen arayüzden değiştirebil diye kilidi açıyoruz
      };

      # HTTPS Zorlama (Güvenlik için eklemeni öneririm)
      HttpsOnlyMode = "force_enabled";
    };
  };

programs.brave = {
    enable = true;
};
}
/etc/nixos/modules🔒
❯ cat yazi.nix
{pkgs, ...}:
{
programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      manager = {
        ratio = [ 1 2 3 ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        image_filter = "lanczos3";
        image_quality = 80; # N4000 için 90 yerine 80 daha akıcı olur
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };

      tasks = {
        micro_workers = 2; # Küçük işler (icon yükleme vs)
        macro_workers = 2; # Büyük işler (dosya kopyalama, önizleme üretme)
        bizarre_retry = 3;
      };
    };
  };
  }
