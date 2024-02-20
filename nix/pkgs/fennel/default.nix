{ version, src, lua, stdenv, pandoc }:

stdenv.mkDerivation rec {
  pname = "fennel";
  inherit version src;

  nativeBuildInputs = [
    lua
    pandoc
  ];

  postPatch = ''
    # Append short commit hash to version string.
    sed -E -i src/fennel/utils.fnl \
        -e "s|(local\s+version\s+:)([^)]*)(\s*\))|\1${version}\3|"

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
}
