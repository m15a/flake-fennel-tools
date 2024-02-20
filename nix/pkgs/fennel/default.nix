{ version, shortRev ? null, src, lua, stdenv, lib, pandoc }:

stdenv.mkDerivation rec {
  pname = "fennel";
  inherit version src;

  nativeBuildInputs = [
    lua
    pandoc
  ];

  postPatch = with lib;
    let
      version' = strings.escapeRegex version;
    in
    optionalString (shortRev != null) ''
      # Append short commit hash to version string.
      sed -E -i src/fennel/utils.fnl \
          -e "s|(local version :)(${version'})(\))|\1${version}-${shortRev}\3|"
    '' + ''
      # FIXME: maninst function and run ./fennel do not work.
      sed -i Makefile \
          -e 's|$(call maninst,$(doc),$(DESTDIR)$(MAN_DIR)/$(doc))|$(shell mkdir -p $(dir $(DESTDIR)$(MAN_DIR)/$(doc)) && cp $(doc) $(DESTDIR)$(MAN_DIR)/$(doc))|' \
          -e 's|\./fennel|lua fennel|'
    '';

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';

  passthru = { inherit lua; };

  meta = with lib; {
    description = "Lua Lisp Language";
    homepage = "https://fennel-lang.org/";
    license = licenses.mit;
    mainProgram = pname;
  };
}
