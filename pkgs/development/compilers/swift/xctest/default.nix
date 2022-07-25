{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, swift
, Foundation
, DarwinTools
}:

stdenv.mkDerivation rec {
  pname = "swift-corelibs-xctest";

  # Releases are made as part of the Swift toolchain, so versions should match.
  version = "5.7";
  src = fetchFromGitHub {
    owner = "apple";
    repo = "swift-corelibs-xctest";
    rev = "swift-${version}-RELEASE";
    hash = "sha256-qLUO9/3tkJWorDMEHgHd8VC3ovLLq/UWXJWMtb6CMN0=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [ cmake ninja swift ]
    ++ lib.optional stdenv.isDarwin DarwinTools; # sw_vers
  buildInputs = [ Foundation ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    # On Darwin only, Swift uses arm64 as cpu arch.
    substituteInPlace cmake/modules/SwiftSupport.cmake \
      --replace '"aarch64" PARENT_SCOPE' '"arm64" PARENT_SCOPE'
  '';

  preConfigure = ''
    # On aarch64-darwin, our minimum target is 11.0, but we can target lower,
    # and some dependants require a lower target. Harmless on non-Darwin.
    export MACOSX_DEPLOYMENT_TARGET=10.12
  '';

  cmakeFlags = lib.optional stdenv.isDarwin "-DUSE_FOUNDATION_FRAMEWORK=ON";

  postInstall = lib.optionalString stdenv.isDarwin ''
    # Darwin normally uses the Xcode version of XCTest. Installing
    # swift-corelibs-xctest is probably not officially supported, but we have
    # no alternative. Fix up the installation here.
    mv $out/lib/swift/darwin/${swift.swiftArch}/* $out/lib/swift/darwin
    rmdir $out/lib/swift/darwin/${swift.swiftArch}
    mv $out/lib/swift/darwin $out/lib/swift/${swift.swiftOs}
  '';

  meta = {
    description = "Framework for writing unit tests in Swift";
    homepage = "https://github.com/apple/swift-corelibs-xctest";
    platforms = lib.platforms.all;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dtzWill trepetti dduan trundle stephank ];
  };
}
