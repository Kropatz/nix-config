{
  lib,
  fetchPypi,
  python3Packages,
  swig,
  pkgconf,
  openssl,
  virustotal-api,
  ...
}:
python3Packages.buildPythonApplication rec {
  pname = "peframe_ds";
  version = "7.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Z9/hMD3w4ZYcfPMbLUuyKhS1wWGT11Y3gdVNVqSdhvg=";
  };
  build-system = with python3Packages; [ setuptools ];
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "readline" "gnureadline"
  '';

  dependencies = with python3Packages; [
    pefile
    yara-python
    python-magic
    requests
    oletools
    m2crypto
    virustotal-api
    gnureadline
  ];

  nativeBuildInputs = [
    swig
    pkgconf
    openssl
  ];

  meta = with lib; {
    description = "PEframe — static analysis of PE files and suspicious documents";
    homepage = "https://github.com/guelfoweb/peframe";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
  };
}
