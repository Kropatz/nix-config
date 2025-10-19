{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage rec {
  pname = "virustotal-api";
  version = "1.1.11";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nx14OoSOkop4qhaDcmRcaJnLvWuIiVHh1jNeW4feHD0=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    requests
  ];

  meta = {
    changelog = "https://github.com/blacktop/virustotal-api/releases/tag/${version}";
    homepage = "https://github.com/blacktop/virustotal-api";
    description = "Virus Total Public/Private/Intel API";
    license = lib.licenses.mit;
  };
}
