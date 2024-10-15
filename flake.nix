{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
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
      formatter = eachSystem (
        system:
        (treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }).config.build.wrapper
      );
    };
}
