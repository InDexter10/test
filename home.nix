{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------
  home.username = "dx5";
  home.homeDirectory = "/home/dx5";
  home.stateVersion = "25.11";
  
  programs.home-manager.enable = true;

  # ---------------------------------------------------------
  # 2. TEMEL SİSTEM ARAÇLARI & BAĞIMLILIKLAR
  # ---------------------------------------------------------
  home.packages = with pkgs; [
    # -- Yazi & Terminal Gereksinimleri --
    ripgrep     # Yazi ve Nvim için ultra hızlı arama
    fd          # Find alternatifi (Yazi kullanır)
    fzf         # Bulanık arama (Zsh ve Yazi kullanır)
    jq          # JSON işleyici
    zoxide      # Akıllı 'cd' komutu (Zsh entegrasyonu aşağıda)

    # -- Grafik Arayüz Gereksinimleri --
    wl-clipboard # Panoya kopyalama (Alacritty/Neovim için şart)
    libnotify    # Bildirim gönderme aracı
    kdePackages.okular
    steam-run
    temurin-bin-11
    xfce.thunar
    xfce.thunar-archive-plugin  
  ];

  # ---------------------------------------------------------
  # 3. SWAY WM (Hibrit Yapı)
  # ---------------------------------------------------------
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false; # Kendi configin olduğu için syntax check'i atlıyoruz (Hata riskini azaltır)
    
    extraConfig = builtins.readFile ./sway.conf;
    
    extraPackages = with pkgs; [
      swaylock
      swayidle
      grim  # Screenshot
      slurp # Seçim
    ];
  };

  # ---------------------------------------------------------
  # 4. BAR (Swaybar + i3status-rust)
  # ---------------------------------------------------------
  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 60;
            warning = 20.0;
            alert = 10.0;
          }
          { block = "memory"; format = " $icon $mem_used_percents "; }
          { block = "cpu"; format = " $icon $utilization "; interval = 1; }
          { block = "net"; format = " $icon $ip "; missing_format = " no wifi "; }
          { 
            block = "sound"; 
            format = " $icon $volume "; 
            headings = false; # Tıklayınca ses kontrolü açar (pavucontrol varsa)
          }
          { block = "time"; format = " $timestamp.datetime(f:'%H:%M') "; interval = 60; }
        ];
        settings = {
          theme = {
            theme = "dracula"; # Veya "solarized-dark", "slick"
            overrides = {
              idle_bg = "#1e1e2e";
              idle_fg = "#cdd6f4";
            };
          };
          icons = { icons = "awesome6"; }; # FontAwesome ikonları
        };
      };
    };
  };

  # NOT: Sway config dosyanın içine şu satırı eklemelisin:
  # bar {
  #   status_command i3status-rs ~/.config/i3status-rust/config-top.toml
  #   position top
  #   font pango:JetBrainsMono Nerd Font 10
  # }
  # (Bunu Nix otomatik yapamaz çünkü config'i harici dosyadan çekiyoruz)

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
  # 6. TERMINAL (Alacritty)
  # ---------------------------------------------------------
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        opacity = 0.95;
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
  # 7. DOSYA YÖNETİCİSİ (Yazi)
  # ---------------------------------------------------------
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------
  # 8. ZELLIJ (Basit & Etkili)
  # ---------------------------------------------------------
  programs.zellij = {
    enable = true;
  };

  # ---------------------------------------------------------
  # 9. NEOVIM (Manuel Yönetim)
  # ---------------------------------------------------------
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # ---------------------------------------------------------
  # 10. SHELL (Zsh + Starship - Optimize Edilmiş)
  # ---------------------------------------------------------
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true; 
    autosuggestion.enable = true;
    enableCompletion = true;
    
    initExtra = ''
      eval "$(zoxide init zsh)"
    '';

    shellAliases = {
      l = "ls -la";
      c = "clear";
      # Konfigürasyon kısayolları
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
