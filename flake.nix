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
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
    in
    {
      overlays.default = final: prev: {
        python310 = prev.python310.override {
          packageOverrides = python-final: python-prev: {
            sora-sdk = python-final.callPackage ./package.nix {
              python_abi = "cp310";
              hash = "sha256-JLg+DSFao8ymPd+xE9mxE+lph2e8K+YT6x0Ao050O+Q=";
            };
          };
        };
        python311 = prev.python311.override {
          packageOverrides = python-final: python-prev: {
            sora-sdk = python-final.callPackage ./package.nix {
              python_abi = "cp311";
              hash = "sha256-0MIa3pDJdz8GwGBjLkAwETW9rR3IOzfpSlfXB3tsXsA=";
            };
          };
        };
        python312 = prev.python312.override {
          packageOverrides = python-final: python-prev: {
            sora-sdk = python-final.callPackage ./package.nix {
              python_abi = "cp312";
              hash = "sha256-PsleIv30BcVejl2fp3XDMG93eJKbfIe/A3hsjpsUVog=";
            };
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
              name = "3.10";
              path = pkgs.python310.pkgs.sora-sdk;
            }
            {
              name = "3.11";
              path = pkgs.python311.pkgs.sora-sdk;
            }
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
