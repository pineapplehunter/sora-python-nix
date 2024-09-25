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
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            sora-sdk = python-final.callPackage ./package.nix { };
          })
        ];
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
    };
}
