{ fetchPypi
, python3
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "Trac";
  version = "1.6";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Ydc8YfZw1o/8NGgp0ksvHSBQqlYapxy5ji+0OZLCcwQ=";
  };

  nativeBuildInputs = [];
  buildInputs = [];
  propagatedBuildInputs = [
    python3Packages.setuptools
    python3Packages.jinja2 
    python3Packages.pygments
    python3Packages.psycopg2
  ];
  pythonImportsCheck = [ "trac" ];


  outputs = [ "out" ];
  
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest \
      -k tests \
      -k admin \
      -k ticket \
      # Ignore wiki folder, broken (won't even start, test.py is badly written?)
      # -k wiki
    runHook postCheck
  '';

  meta = {
    description = "Minimalistic web-based software project management and bug/issue tracking system";
    longDescription = ''
      Trac is an enhanced wiki and issue tracking system for software development projects. 
      Trac uses a minimalistic approach to web-based software project management.
      Our mission is to help developers write great software while staying out of the way.
      Trac should impose as little as possible on a team's established development process and policies.
    '';
    homepage = "https://trac.edgewall.org/";
    license = lib.licenses.bsd3
  };
}
