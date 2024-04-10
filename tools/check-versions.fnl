#!/usr/bin/env fennel

(local unpack (or table.unpack _G.unpack))

(fn sh [cmd]
  (->> (with-open [p (assert (io.popen cmd))]
         (string.gsub (p:read :*a) "%s+$" ""))
       (pick-values 1)))

(fn command-to-get-expected-version [pkg-name]
  (let [pkg-name (pkg-name:match "(.*)%-unstable")]
    (.. "jq -r '.[\"" pkg-name "\"]' data/unstable-versions.json 2>/dev/null")))

(fn check-version [pkg-name command-to-get-actual-version]
  "Check version consistency for the package."
  (let [expected (sh (command-to-get-expected-version pkg-name))
        actual (sh command-to-get-actual-version)
        actual-without-hash (actual:gsub "%-[0-9a-fA-F]+$" "")]
    (if (= expected actual-without-hash)
        (do
          (-> (string.format "[OK] %s: %s" pkg-name actual)
              (io.stderr:write "\n"))
          true)
        (do
          (-> (string.format "[ERROR] %s: expected %s does not match actual %s"
                             pkg-name expected actual)
              (io.stderr:write "\n"))
          false))))

(fn | [& commands]
  "Connect shell commands with pipes."
  (table.concat commands " | "))

(macro do-checks [& checks]
  (let [ok? `ok?#
        checks (icollect [_ check (ipairs checks)]
                 `(when (not ,check) (set ,ok? false)))]
    `(do
       (var ,ok? true)
       ;; NOTE: unpack does not exactly do unquote-splicing if there're extra
       ;; tails!
       ,(unpack (doto checks
                  (table.insert `(os.exit ,ok?)))))))


(fn command-to-get-fennel-ls-version [changelog-path dev?]
  (let [vregex "[[:digit:]]+\\.[[:digit:]]+\\.[[:digit:]]+"]
    (| (.. "grep -Em1 '^## " vregex "' " changelog-path " 2>/dev/null")
       (.. "sed -E 's|## ([^\\s]+)|\\1" (if dev? "-dev" "") "|'"))))

(do-checks
  (check-version
    :fennel-unstable
    (| "fennel --version 2>/dev/null"
       "cut -d' ' -f2"))
  (check-version
    :faith-unstable
    "fennel --eval \"(print (. (require :faith) :version))\" 2>/dev/null")
  (check-version
    :fnlfmt-unstable
    (| "fnlfmt --version 2>/dev/null"
       "cut -d' ' -f3"))
  (check-version
    :fennel-ls-unstable
    (command-to-get-fennel-ls-version "$FENNEL_LS_UNSTABLE_CHANGELOG_PATH"
                                      :dev)))
