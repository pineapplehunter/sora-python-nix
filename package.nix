{
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  libX11,
  libva,
}:

buildPythonPackage rec {
  pname = "sora-sdk";
  version = "2024.3.0";
  format = "wheel";

  src = fetchPypi {
    pname = "sora_sdk";
    inherit version format;
    python = "cp312";
    abi = "cp312";
    dist = "cp312";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    hash = "sha256-PsleIv30BcVejl2fp3XDMG93eJKbfIe/A3hsjpsUVog=";
  };

  pythonImportsCheck = [ "sora_sdk" ];

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libX11
    libva
  ];
}
