{
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  libX11,
  libva,
  lib,
  numpy,
  stdenv,
}:
let
  platformData =
    {
      x86_64-linux = {
        platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
        hash = "sha256-PsleIv30BcVejl2fp3XDMG93eJKbfIe/A3hsjpsUVog=";
      };
      aarch64-darwin = {
        platform = "macosx_14_0_arm64";
        hash = "sha256-a/Fr14/J1pwbpgCm4wCXk3VlBC9RbgYCsfzVoXyYIGI=";
      };
    }
    .${stdenv.hostPlatform.system};
in
buildPythonPackage rec {
  pname = "sora-sdk";
  version = "2024.3.0";
  format = "wheel";

  src = fetchPypi {
    pname = "sora_sdk";
    inherit version format;
    inherit (platformData) platform hash;
    python = "cp312";
    abi = "cp312";
    dist = "cp312";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libX11
    libva
  ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  dependencies = [ numpy ];

  pythonImportsCheck = [ "sora_sdk" ];

  meta = {
    description = "WebRTC SFU Sora Python SDK";
    homepage = "https://github.com/shiguredo/sora-python-sdk";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.pineapplehunter ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvince = [ lib.sourceTypes.binaryNativeCode ];
  };
}
