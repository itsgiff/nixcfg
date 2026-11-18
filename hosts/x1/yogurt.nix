# Yogurt: AI meeting notes that record calls without a bot joining
# (github.com/FrigadeHQ/yogurt). Not in nixpkgs, and the only Linux build is
# an AppImage, so wrap the release AppImage. To update: change version, set
# hash = lib.fakeHash, build, and copy the real hash from the error.
{ lib, appimageTools, fetchurl }:

let
  pname = "yogurt";
  version = "0.3.7";

  src = fetchurl {
    url = "https://github.com/FrigadeHQ/yogurt/releases/download/v${version}/Yogurt-linux-x86_64.AppImage";
    hash = "sha256-Gs59xz2BKT25KKpjlz1tgbNCb+mtmxEIGiKdI67bpoE=";
  };

  # Unpacked AppImage, for its .desktop file and icon
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The AppImage's own entry runs AppRun; point it at the wrapper in $out/bin.
  # The app's launch script already switches to XWayland on GNOME Wayland.
  extraInstallCommands = ''
    install -Dm444 ${contents}/yogurt.desktop $out/share/applications/yogurt.desktop
    substituteInPlace $out/share/applications/yogurt.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=yogurt --no-sandbox %U'
    install -Dm444 ${contents}/usr/share/icons/hicolor/1024x1024/apps/yogurt.png \
      $out/share/icons/hicolor/1024x1024/apps/yogurt.png
  '';

  meta = {
    description = "Private, open-source AI meeting notes";
    homepage = "https://github.com/FrigadeHQ/yogurt";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "yogurt";
  };
}
