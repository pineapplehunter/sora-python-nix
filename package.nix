{
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  libX11,
  libva,
  lib,
  python_abi,
  hash,
}:

buildPythonPackage rec {
  pname = "sora-sdk";
  version = "2024.3.0";
  format = "wheel";

  src = fetchPypi {
    pname = "sora_sdk";
    inherit version format;
    python = python_abi;
    abi = python_abi;
    dist = python_abi;
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    inherit hash;
  };

  pythonImportsCheck = [ "sora_sdk" ];

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    libX11
    libva
  ];

  meta = {
    description = "WebRTC SFU Sora Python SDK";
    homepage = "https://github.com/shiguredo/sora-python-sdk";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.pineapplehunter ];
    platforms = [ "x86_64-linux" ];
    sourceProvince = [ lib.sourceTypes.binaryNativeCode ];
  };
}
