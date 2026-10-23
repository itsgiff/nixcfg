# ~/.nixcfg/modules/vscode.nix
{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    # Extensions and settings live under profiles.default (Home Manager 25.05+)
    profiles.default = {
      # VS Code extensions
      extensions = with pkgs.vscode-extensions; [
        # Core extensions
        pkief.material-icon-theme
      
        # Kubernetes
        ms-kubernetes-tools.vscode-kubernetes-tools
        
        # Add more extensions as needed
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Extensions not in nixpkgs can be added here with:
        # {
        #   name = "extension-name";
        #   publisher = "publisher-name";
        #   version = "version";
        #   sha256 = "sha256-hash"; # use `nix-prefetch-url` to get this
        # }
      ];
      
      # User settings
      userSettings = {
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "newUntitledFile";
        "extensions.ignoreRecommendations" = true;
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.openRepositoryInParentFolders" = "always";
        
        "redhat.telemetry.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "security.workspace.trust.banner" = "never";
        "security.workspace.trust.startupPrompt" = "never";
        
        "editor.fontFamily" = "'Fira Code', Menlo, monospace";  # Fira Code on the x1, Menlo (VS Code's default) on the Mac
        "update.showReleaseNotes" = false;
        "[python]" = {
          "editor.formatOnType" = true;
        };
        "workbench.editor.empty.hint" = "hidden";
        "workbench.navigationControl.enabled" = false;
        
        "vs-kubernetes" = {
          "vscode-kubernetes.kubectl-path-mac" = "/Users/paul/.vs-kubernetes/tools/kubectl/kubectl";
          "vscode-kubernetes.helm-path-mac" = "/Users/paul/.vs-kubernetes/tools/helm/darwin-arm64/helm";
          "vscode-kubernetes.minikube-path-mac" = "/Users/paul/.vs-kubernetes/tools/minikube/darwin-arm64/minikube";
        };
      };
    };
  };
}