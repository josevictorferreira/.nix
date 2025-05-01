{ pkgs, configRoot, ... }:

let
  neovimConfigDir = "${configRoot}/config/nvim";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = builtins.readFile "${neovimConfigDir}/init.lua";
  };

  home = {
    # Neovim External Dependencies By Some Plugins
    packages = with pkgs; [
      fzf
      ripgrep
      cargo
      rustc
      nixd
    ];

    file = {
      ".config/nvim/lua" =
        {
          source = "${neovimConfigDir}/lua";
          recursive = true;
          executable = false;
        };
      ".config/nvim/schemas" =
        {
          source = "${neovimConfigDir}/schemas";
          recursive = true;
          executable = false;
        };
      ".config/nvim/after" =
        {
          source = "${neovimConfigDir}/after";
          recursive = true;
          executable = false;
        };
      ".config/nvim/snippets" =
        {
          source = "${neovimConfigDir}/snippets";
          recursive = true;
          executable = false;
        };
    };
  };
}
