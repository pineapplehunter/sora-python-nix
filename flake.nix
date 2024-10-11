{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      overlays.default = final: prev: {
        python312 = prev.python312.override {
          packageOverrides = python-final: python-prev: {
            sora-sdk = python-final.callPackage ./package.nix { };
          };
        };
      };
      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.python3.pkgs.sora-sdk;
          all = pkgs.linkFarm "sora-sdk-all" [
            {
              name = "3.12";
              path = pkgs.python312.pkgs.sora-sdk;
            }
          ];
          python = pkgs.python3.withPackages (
            ps:
            builtins.attrValues {
              inherit (ps)
                sora-sdk
                ;
            }
          );
        }
      );
      legacyPackages = eachSystem pkgsFor;
    };
}
