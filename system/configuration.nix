{ config, pkgs, lib, unstable, home, nur, inputs, nixpkgs, overlays, ... }:

let

myneovim = pkgs.neovim.override {
configure =
{
customRC =
''
let g:lightline = {
\ 'colorscheme': 'jellybeans',
\ }
syntax on
set number
set mouse=a
nnoremap <C-n> :NERDTree<CR>
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "normal! g`\"" |
\ endif
'';
plug.plugins = with pkgs.vimPlugins;
[
vim-nix
vim-closetag
lightline-vim
coc-nvim
];
};
};

stable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz) { config = config.nixpkgs.config; };

in

{
  imports = [
     ./hardware-configuration.nix
#     ./home.nix
  ];
#  home-manager = { users.reimu = (import ./home.nix {inherit config pkgs lib unstable;}); };
nixpkgs = {
  overlays = 
    let
    # Change this to a rev sha to pin
    moz-rev = "master";
    moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
    nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
    in [
    nightlyOverlay
    ];
    config = {
      firefox.enablePlasmaBrowserIntegration = true;
      allowUnfree = true;
      allowBroken = true;
    };
  };

  nix = {
#    binaryCaches = [ "https://cache.nixos.org" "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    package = pkgs.nixUnstable;
    autoOptimiseStore = true;
#    extraOptions = ''
#      experimental-features = nix-command flakes
#      '';
    };

  virtualisation = {
    virtualbox = {
      host.enable = true;
      #host.enableExtensionPack = true;
    };
  };
  programs = {
    dconf.enable = true;
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "agnoster";
      };
      shellAliases = {
        l = "ls -alh";
        ll = "ls -l";
        nrsu = "sudo nixos-rebuild switch --upgrade";
        nrs = "sudo nixos-rebuild switch";
        hms = "home-manager switch";
        hmsu = "home-manager switch --upgrade";
        tb = "nc termbin.com 9999";
        editcfg = "sudo nvim /etc/nixos/configuration.nix";
        edithome = "nvim ~/.config/nixpkgs/home.nix";
        o = "nvidia-offload";
        ncfg = "sudo cp -r /etc/nixos/* ~/nixcfg/system && sudo cp -r ~/.config/nixpkgs/* ~/nixcfg/home-manager";
      };
    };
    gnupg.agent.enable = true;
  };
  time.timeZone = "Europe/Moscow";
  sound.enable = true;
  system.stateVersion = "20.03";

  networking = {
    hostName = "nixos";
    nameservers = [ "1.1.1.1" ];
    firewall.enable = false;
    dhcpcd.wait = "background";
    interfaces.wlp2s0.useDHCP = true;
    interfaces.enp3s0.useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlp2s0" ];
      networks."reimuware inc. v1.7".psk = "senpai_love_touhou";
      networks."covid_generator".psk = "LizzyMarie6";
    };
  };

  hardware = {
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ intel-media-driver vaapiVdpau libvdpau-va-gl ];
    };
    nvidia.prime = {
      sync.enable = true;
      #offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  boot = {
    supportedFilesystems = [ "xfs" "ntfs" "f2fs" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };
  
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    meslo-lg
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts
  dina-font
  proggyfonts
  ];

  environment.systemPackages = with pkgs; [ 
    # test
    #polybar
    #feh
    #rofi
    #maim
    bpytop
    brightnessctl
    xclip
    openjdk8
    gparted
    pywal
    qbittorrent
    pavucontrol
    pulseaudio
    playerctl
    sakura

    woeusb
    gnupg
    emacs
    tdesktop
    git
    nodejs
    myneovim
    vim
    hello
    latte-dock
    htop
    google-chrome
    discord
    steam
    firefox
    spotify
    pulseeffects-legacy
    atom
    minecraft
    remmina
    libsForQt5.qtstyleplugin-kvantum
    etcher
    vlc
    kate
    ark
    filelight
    exodus
    adoptopenjdk-jre-openj9-bin-8
    leafpad
    noisetorch
    obs-studio
    neofetch
    glxinfo
    krita

    # nightly
    latest.firefox-nightly-bin

    # montage
    kdenlive

#    python39Packages.pip
#    python39Packages.pynput
    python38Full
    piper
    vk-messenger
    appimage-run
    vscode
    xvidcore
    osu-lazer

    #birthday?
    opentabletdriver

    #anon
    tor-browser-bundle-bin

    #emulator
    wineWowPackages.full
    lutris
    playonlinux

    # scripts
    (pkgs.writeShellScriptBin "nvidia-offload" ''__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"'')
];

services = {
    ratbagd.enable = true;
    blueman.enable = true;
    printing.enable = true;
    openssh.enable = true;
    haveged.enable = true;
    tor.enable = true;
    tor.client.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "us,ru";
      dpi = 96;
      displayManager = {
#        sddm.enable = true;
        defaultSession = "plasma5";
        lightdm.greeters.mini = {
          enable = true;
          user = "reimu";
          extraConfig = ''
            [greeter]
            show-password-label = false
            [greeter-theme]
            background-image = ""
            '';
          };
        };
      desktopManager = {
        plasma5.enable = true;
      };
      libinput.enable = true;
#      desktopManager.xterm.enable = false;
#      displayManager.defaultSession = "none+i3";
#      windowManager.i3 = {
#        package = pkgs.i3-gaps;
#        enable = true;
#        extraPackages = with pkgs; [
#          dmenu #application launcher most people use
#          i3status # gives you the default i3 status bar
#          i3lock #default i3 screen locker
#          i3blocks #if you are planning on using i3blocks over i3status
#       ];
#      };
    };
  };

  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd --noplugin=avrcp"
  ];

  users = {
    mutableUsers = false;
    users.reimu = {
      isNormalUser = true;
      hashedPassword = "$5$W7lyoN9pWq2/BH9F$jXaIpFZy3L9NgqrZhK382rre.ljdmLlHzvKvVQ1s3VA";
      extraGroups = [ "wheel" "audio" "video" "vboxusers" ];
      shell = pkgs.zsh;
    };
  };
}
