{ config, pkgs, ... }:

{
  ########################################################################
  # Home Manager setup for user: jkutz
  ########################################################################
  home-manager.users.jkutz = { pkgs, lib, config, ... }: {
    # State version — keep it pinned to when you first set up HM
    home.stateVersion = "25.05";

    ######################################################################
    # XDG integration (ensures ~/.nix-profile/share/applications is picked up)
    ######################################################################
    xdg.enable = true;

# Make Alacritty the defaul terminal in Cinnamon
dconf.settings = {
    "org/cinnamon" = {
				favorite-apps = [ "Alacritty.desktop" ];
			};

    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "alacritty";
      exec-arg = "-e";
    };
  };

# Desktop search prefers Alacritty for "terminal"
xdg.desktopEntries.alacritty = {
  name = "Terminal";
  genericName = "Terminal Emulator";
  exec = "alacritty";
  icon = "Alacritty";
  terminal = false;
  categories = [ "System" "Utility" "TerminalEmulator" ];
  # Only show in Cinnamon (optional):
  # onlyShowIn = [ "Cinnamon" ];
};

    ######################################################################
    # Basic programs
    ######################################################################
    programs.home-manager.enable = true;

    programs.git = {
      enable = true;
      userName  = "John Kutz";
      userEmail = "johnandrew.kutz@gmail.com";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    ######################################################################
    # Terminal: Alacritty
    ######################################################################
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = { family = "0xProto Nerd Font"; };
          bold   = { family = "0xProto Nerd Font"; };
          italic = { family = "0xProto Nerd Font"; };
          size   = 12.0; # adjust font size as you like
        };

        window = {
          opacity = 0.95;
          padding = { x = 6; y = 6; };
        };
      };
    };

    ######################################################################
    # Dev tools your Neovim config expects
    ######################################################################
    home.packages = with pkgs; [
      ripgrep fd
      gcc gnumake pkg-config cmake
      xclip
      lua-language-server stylua
      go gofumpt gotools golines
      nodejs jq nodePackages.prettier

      # Fonts (per-user install, travels with HM)
      nerd-fonts._0xproto
    ];

    ######################################################################
    # Fonts (per-user, not in system configuration.nix)
    ######################################################################
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "0xProto Nerd Font" ];
      };
    };

    ######################################################################
    # Neovim config from GitHub (clone/update into ~/.config/nvim)
    ######################################################################
    home.activation.nvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -eu
      git="${pkgs.git}/bin/git"
      repo="https://github.com/Iztuk/neovim-config.git"  # switch to SSH later if desired
      cfg="${config.home.homeDirectory}/.config/nvim"

      # If ~/.config/nvim exists but isn't a git repo (or is a read-only symlink), back it up.
      if [ -e "$cfg" ] && [ ! -d "$cfg/.git" ]; then
        ts=$(date +%s)
	echo "Backing up existing $cfg to $cfg.bak.$ts"
	mv -f "$cfg" "$cfg.bak.$ts"
      fi

      if [ -d "$cfg/.git" ]; then
        echo "Updating Neovim config in $cfg …"
	"$git" -C "$cfg" pull --ff-only
      else
        echo "Cloning Neovim config into $cfg …"
	mkdir -p "$(dirname "$cfg")"
	"$git" clone --depth 1 "$repo" "$cfg"
      fi
     '';

    ######################################################################
    # Environment variables
    ######################################################################
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";

      
# =====================================================================
  # NOTE: Root setup (optional, personal machines only)
  #
  # Option 1: Temporary export (only lasts for the session):
  #   sudo -i export EDITOR=nvim VISUAL=nvim
  #
  # Option 2: Persistent via sudoers (keeps env vars across sudo):
  #   sudo visudo
  #   Add: Defaults env_keep += "EDITOR VISUAL"
  #
  # Option 3: Symlink Neovim config for root (root always uses your config):
  #   sudo mkdir -p /root/.config
  #   sudo ln -s /home/jkutz/.config/nvim /root/.config/nvim
  #
  # ⚠️ Only do Option 2 or 3 on personal machines — not recommended on shared/prod.
  # =====================================================================
};

  };
}

