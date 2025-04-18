{ pkgs, lib, config, configRoot, ... }:

with lib;
let
  cfg = config.modules.weechat;
  defaultScripts = with pkgs.weechatScripts; [
    wee-slack
    weechat-autosort
    weechat-go
    weechat-notify-send
    url_hint
    edit
    multiline
    highmon
    colorize_nicks
  ];
in
{
  options.modules.weechat = {
    enable = mkEnableOption "weechat";
    additionalScripts = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "List of weechat scripts to install.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = [
        (pkgs.weechat.override {
          configure = { availablePlugins, ... }: {
            plugins = with availablePlugins; [
              lua
              perl
              (python.withPackages (p: with p; [ websocket-client ]))
            ];
            scripts = cfg.additionalScripts ++ defaultScripts;
            init = ''
              /script install vimode.py
              /script install emoji.lua

              /set weechat.bar.input.items "[mode_indicator]+[input_prompt]+(away),[input_search], [input_paste],input_text,[vi_buffer]"
              /set weechat.bar.vi_line_numbers.hidden off
              /set weechat.look.mouse on
              /set weechat.look.prefix_same_nick "⤷"
              /set weechat.look.color_nick_offline yes
              /set weechat.look.align_end_of_lines time
              /set weechat.look.align_multiline_words on

              /set weechat.bar.nicklist.conditions "$${info:term_width} > 100"
              /set weechat.bar.nicklist.size_max 30

              /set weechat.bar.title.color_fg black
              /set weechat.bar.title.color_bg 31
              /set weechat.bar.nicklist.color_fg 229
              /set weechat.bar.nicklist.separator on
              /set weechat.bar.nicklist.size_max 20
              /set weechat.bar.nicklist.size 16

              /set spell.enable "true"
              /set spell.check.default_dict "en,pt_BR"
              /set spell.option.ignore-case "true"
              /set aspell.check.default_dict pt_BR
              /set aspell.check.suggestions 3
              /set aspell.color.suggestions *green
              /set aspell enable

              /set plugins.var.python.slack.files_download_location "~/Downloads/weeslack"
              /set plugins.var.python.slack.auto_open_threads true
              /set plugins.var.python.slack.never_away true
              /set plugins.var.python.slack.render_emoji_as_string false
              /set plugins.var.python.slack.show_buflist_presense true
              /set plugins.var.python.slack.show_emoji true
              /set plugins.var.python.slack.show_emoji_reactions true
              /set plugins.var.python.slack.show_emoji_reactions_in_threads true
              /set plugins.var.python.vimode.search_vim on

              /set bind ctrl-g /go
              
              /autojoin
              /save
            '';
          };
        })
      ];
    };
  };
}
