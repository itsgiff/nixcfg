{ config, pkgs, ... }:

{
  #nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;  # Explicitly reference the system package
    
    # Using the new profiles API
    profiles.default = {
      # VS Code extensions - adding common ones based on your setup
      extensions = with pkgs.vscode-extensions; [
        # Core extensions
        pkief.material-icon-theme
        
        # Python support
        ms-python.python
        
        # Git integration
        github.copilot # Requires allowUnfree
        
        # Kubernetes
        ms-kubernetes-tools.vscode-kubernetes-tools
        
        # Add more extensions from your list as needed
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # Extensions not in nixpkgs can be added here with:
        # {
        #   name = "extension-name";
        #   publisher = "publisher-name";
        #   version = "version";
        #   sha256 = "sha256-hash"; # use `nix-prefetch-url` to get this
        # }
      ];
      
      # Migrated user settings to the new profiles format
      userSettings = {
        "workbench.iconTheme" = "material-icon-theme";
        "sync.gist" = "2debdea5a28c7b4446548f427f607cb8";
        "sync.autoDownload" = true;
        "sync.autoUpload" = true;
        "workbench.startupEditor" = "newUntitledFile";
        "extensions.ignoreRecommendations" = true;
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.openRepositoryInParentFolders" = "always";
        
        "redhat.telemetry.enabled" = true;
        "security.workspace.trust.untrustedFiles" = "open";
        "security.workspace.trust.banner" = "never";
        "security.workspace.trust.startupPrompt" = "never";
        
        "editor.fontFamily" = "'Noto', 'monospace', 'Hack Nerd Font', 'Weather Icons', 'Font Awesome 5 Free', 'icomoon-feather', 'unifont', 'Material'";
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