final: _:

with final;

rec {
  checks = {
    versions =
      runCommand "check-versions"
        {
          src = ../.;
          nativeBuildInputs = [
            fennel-unstable-luajit
            fnlfmt-unstable
            jq.bin
          ];
          FENNEL_PATH = "${faith-unstable}/bin/?";
          FENNEL_LS_UNSTABLE_CHANGELOG_PATH =
            runCommand "fennel-ls-unstable-changelog" { inherit (fennel-ls-unstable) src; }
              ''
                tar xf $src --wildcards '*/changelog.md'
                cp */changelog.md $out
              '';
        }
        ''
          set -e
          fennel $src/tools/check-versions.fnl
          touch $out
        '';
  };

  devShells = rec {
    default = mkShell {
      inputsFrom = [
        ci-update
      ];
      packages = [
        fennel-ls-unstable
        luajit.pkgs.readline
      ];
    };

    ci-update = mkShell {
      packages = [
        nix
        jq.bin
        (fennel-luajit.withLuaPackages (
          ps: with ps; [
            http
            cjson
          ]
        ))
      ];
    };
  };
}
