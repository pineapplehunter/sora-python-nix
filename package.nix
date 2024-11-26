{
  autoPatchelfHook,
  buildPythonPackage,
  fetchurl,
  lib,
  libX11,
  libva,
  numpy,
  python,
  stdenv,
}:
let
  version = lib.strings.trim (builtins.readFile ./version.txt);
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  cp =
    let
      inherit (python.sourceVersion) major minor;
    in
    "cp${major}${minor}";
  source_key =
    if stdenv.hostPlatform.isDarwin then
      "sora_sdk-${version}-${cp}-${cp}-macosx_14_0_arm64.whl"
    else
      "sora_sdk-${version}-${cp}-${cp}-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
in
buildPythonPackage {
  pname = "sora-sdk";
  inherit version;
  format = "wheel";

  disabled = !builtins.hasAttr source_key sources;

  src = fetchurl {
    inherit (sources.${source_key}) url sha256;
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
