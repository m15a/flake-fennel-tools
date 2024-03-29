#!/usr/bin/env fennel

(local unpack (or table.unpack _G.unpack))

(fn get-command-output [command]
  (->> (with-open [p (assert (io.popen command))]
         (string.gsub (p:read :*a) "%s+$" ""))
       (pick-values 1)))

(fn command-to-get-expected-version [package-name]
  (.. "jq -r '.[\"" package-name "\"]' nix/pkgs/versions.json 2>/dev/null"))

(fn check-version [package-name command-to-get-actual-version]
  "Check version consistency for the package."
  (let [expected (get-command-output (command-to-get-expected-version package-name))
        actual (get-command-output command-to-get-actual-version)
        actual-without-hash (actual:gsub "%-[0-9a-fA-F]+$" "")]
    (if (= expected actual-without-hash)
        (do
          (-> (string.format
                "[OK] %s: %s\n"
                package-name
                actual)
              (io.stderr:write))
          true)
        (do
          (-> (string.format
                "[ERROR] %s: expected %s does not match actual %s"
                package-name
                expected
                actual)
              (io.stderr:write))
          false))))

(fn pipe [& commands]
  "Connect shell commands with pipes."
  (table.concat commands " | "))

(macro do-checks [& checks]
  (let [ok? `ok?#
        checks (icollect [_ check (ipairs checks)]
                 `(when (not ,check) (set ,ok? false)))]
    `(do
       (var ,ok? true)
       ;; NOTE: unpack does not exactly do unquote-splicing if there're extra tails!
       ,(unpack (doto checks
                  (table.insert `(os.exit ,ok?)))))))

(do-checks

  (check-version
    :fennel-stable
    (pipe
      "fennel --version 2>/dev/null"
      "cut -d' ' -f2"))

  (check-version
    :fennel-unstable
    (pipe
      "fennel-unstable --version 2>/dev/null"
      "cut -d' ' -f2"))

  (check-version
    :faith-stable
    "fennel --eval \"(print (. (require :faith) :version))\" 2>/dev/null")

  (check-version
    :faith-unstable
    "fennel --eval \"(print (. (require :faith-unstable) :version))\" 2>/dev/null")

  (check-version
    :fnlfmt-stable
    (pipe
      "fnlfmt --version 2>/dev/null"
      "cut -d' ' -f3"))

  (check-version
    :fnlfmt-unstable
    (pipe
      "fnlfmt-unstable --version 2>/dev/null"
      "cut -d' ' -f3"))

  (check-version
    :fenneldoc
    (pipe
      "grep 'FENNELDOC_VERSION =' $FENNELDOC_PATH 2>/dev/null"
      "cut -d' ' -f3"
      "sed -E 's|\\[\\[([^]]+)]]|\\1|'"))

  (check-version
    :fennel-ls-stable
    (pipe
      "grep -E '^## [[:digit:]]+\\.[[:digit:]]+' $FENNEL_LS_CHANGELOG_PATH 2>/dev/null"
      "head -n1"
      "sed -E 's|## ([^\\s]+)|\\1|'"))

  (check-version
    :fennel-ls-unstable
    "echo TODO"))
