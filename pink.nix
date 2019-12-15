{stdenvNoCC, makeWrapper, rakudo}:
stdenvNoCC.mkDerivation {
    name = "pink";
    buildInputs = [makeWrapper];
    phases = ["unpackPhase" "buildPhase" "installPhase"];
    unpackPhase = ''
        cp             ${./META6.json} META6.json
        cp --recursive ${./bin} bin
        cp --recursive ${./lib} lib
    '';
    buildPhase = ''
        # TODO: Precompile the application.
    '';
    installPhase = ''
        mkdir --parents $out/bin $out/share
        cp --recursive META6.json bin lib $out/share
        makeWrapper ${rakudo}/bin/rakudo $out/bin/pinkc \
            --set PERL6LIB $out/share \
            --add-flags $out/share/bin/pinkc.p6
    '';
}
