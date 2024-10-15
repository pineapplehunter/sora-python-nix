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
      inherit (nixpkgs) lib;
    in
    {
      overlays.default = final: prev: {
        python312 = prev.python312.override (old: {
          packageOverrides =
            let
              overlay = python-final: python-prev: {
                sora-sdk = python-final.callPackage ./package.nix { };
              };
            in
            lib.composeExtensions (old.packageOverrides or (_: _: { })) overlay;
        });
      };
      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.python3.pkgs.sora-sdk;
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
