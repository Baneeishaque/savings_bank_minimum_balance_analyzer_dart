{ pkgs, ... }: {
  channel = "unstable";

  packages = [
    pkgs.mise
    pkgs.util-linux
  ];

  env = {};
  idx = {
    extensions = [
      "Dart-Code.dart-code"
      "hverlin.mise-vscode"
      "tamasfe.even-better-toml"
      "FittenTech.Fitten-Code"
      "mechatroner.rainbow-csv"
    ];

    previews = {
      enable = true;
      previews = {
      };
    };

    workspace = {
      onCreate = {
        mise-trust = "mise trust --yes";
        mise-install = "mise install";
        dart-pub-get = "mise exec -- dart pub get";
      };
      onStart = {
      };
    };
  };
}
