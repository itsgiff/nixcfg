# ~/.nixcfg/modules/ai/mcp.nix
# MCP servers for Claude Code, the same on both machines. Home Manager writes
# them to ~/.config/mcp/mcp.json and the `claude` wrapper loads them, next to
# the plugins. modules/ai/README.md has the steps to add or remove one.
#
# Never put a token or key in this file: it ends up in the Nix store and on
# the public GitHub mirror. Keep secrets in ~/.config/mcp-secrets/<name> on
# each machine and point env.<VAR>.file at it (see the github example).
#
# Codex is left out on purpose: its MCP servers live in ~/.codex/config.toml,
# which the ChatGPT app writes itself. Add them in the app instead.
{ config, pkgs, ... }:

let
  secret = name: "${config.home.homeDirectory}/.config/mcp-secrets/${name}";
in
{
  programs.mcp = {
    enable = true;

    servers = {
      # NixOS, Home Manager and nix-darwin options and packages, looked up live
      # instead of from the model's memory (search.nixos.org, the Home Manager
      # and nix-darwin manuals, NixHub). Packaged in nixpkgs, so it's pinned
      # with the system and nothing is installed at run time.
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };

      # Examples. Uncomment one (or copy it), then switch.
      #
      # Needs a token, read from a file outside the repo when the server starts.
      # github = {
      #   command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      #   args = [ "stdio" ];
      #   env.GITHUB_PERSONAL_ACCESS_TOKEN.file = secret "github";
      # };
      #
      # Remote (HTTP): sign in from Claude Code with /mcp, no secret here.
      # context7 = {
      #   url = "https://mcp.context7.com/mcp";
      # };
      #
      # Only on npm: pin the version so both machines run the same one.
      # some-server = {
      #   command = "${pkgs.nodejs}/bin/npx";
      #   args = [ "-y" "some-mcp-server@1.2.3" ];
      # };
    };
  };

  programs.claude-code.enableMcpIntegration = true;
}
