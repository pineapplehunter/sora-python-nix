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
  inherit (stdenv)
    isLinux
    isDarwin
    isx86_64
    isAarch64
    ;
  inherit (lib) optionals;
  platformData =
    if isLinux && isx86_64 then
      {
        platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
        hash = "sha256-PsleIv30BcVejl2fp3XDMG93eJKbfIe/A3hsjpsUVog=";
      }
    else if isDarwin && isAarch64 then
      {
        platform = "macosx_14_0_arm64";
        hash = "sha256-a/Fr14/J1pwbpgCm4wCXk3VlBC9RbgYCsfzVoXyYIGI=";
      }
    else
      throw "unsupported target";
in
buildPythonPackage rec {
  pname = "sora-sdk";
  version = "2024.3.0";
  format = "wheel";

  src = fetchPypi {
    pname = "sora_sdk";
    inherit
      version
      format
      ;
    inherit (platformData)
      platform
      hash
      ;
    python = "cp312";
    abi = "cp312";
    dist = "cp312";
  };
  pythonImportsCheck = [ "sora_sdk" ];

  buildInputs = optionals isLinux [
    libX11
    libva
  ];

  nativeBuildInputs = optionals isLinux [ autoPatchelfHook ];

  dependencies = [ numpy ];

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
