#!/usr/bin/env fennel

;;;; BSD 3-Clause License
;;;; 
;;;; Copyright (c) 2024 NACAMURA Mitsuhiro
;;;; 
;;;; Redistribution and use in source and binary forms, with or without
;;;; modification, are permitted provided that the following conditions
;;;; are met:
;;;; 
;;;; 1. Redistributions of source code must retain the above copyright
;;;;    notice, this list of conditions and the following disclaimer.
;;;; 
;;;; 2. Redistributions in binary form must reproduce the above copyright
;;;;    notice, this list of conditions and the following disclaimer in
;;;;    the documentation and/or other materials provided with the
;;;;    distribution.
;;;; 
;;;; 3. Neither the name of the copyright holder nor the names of its
;;;;    contributors may be used to endorse or promote products derived
;;;;    from this software without specific prior written permission.
;;;; 
;;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;;;; FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;;;; COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;;;; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;;;; BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;;;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;;;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;;;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;;; POSSIBILITY OF SUCH DAMAGE.

;;;; Modification of the script (`tools/update.fnl`) in another repo [1].
;;;;
;;;; [1]: https://github.com/m15a/flake-awesome-neovim-plugins/

(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))
(local {: stablepairs} (require :fennel.utils))
(local http/request (require :http.request))
(local cjson (require :cjson.safe))


(macro unless [condition & body]
  `(when (not ,condition)
     ,(unpack body)))


(macro assert/type [type* x]
  `(when (not= ,type* (type ,x))
     (error (.. ,type* " expected, got " (view ,x)))))

(macro assert/?type [type? x]
  `(when (not= nil ,x)
     (assert/type ,type? ,x)))


(fn clone [tbl]
  (collect [k v (pairs tbl)]
    (values k v)))

(fn merge! [tbl* & tbls]
  (each [_ tbl (ipairs tbls)]
    (each [k v (pairs tbl)]
      (set (. tbl* k) v)))
  tbl*)


(fn file->string [path]
  (case (io.open path)
    file (with-open [file file] (file:read :*a))
    (_ msg) (values nil msg)))

(fn string->file [str path]
  (case (io.open path :w)
    file (with-open [file file] (file:write str))
    (_ msg)
    (if (msg:match "No such file or directory")
        (case (os.execute (.. "mkdir -p " (path:match "(.*)/")))
          0 (string->file str path)
          _ (values nil (.. "failed to create directory for '" path "'")))
        (values nil msg))))


(local log (let [mt {:level 1}]
             (set mt.__index mt)
             (fn mt.__call [_ ...] (io.stderr:write ...) (io.stderr:write "\n"))
             (fn mt.debug [s ...] (when (<= s.level 0) (s "[DEBUG] " ...)))
             (fn mt.info [s ...] (when (<= s.level 1) (s "[INFO] " ...)))
             (fn mt.warn [s ...] (when (<= s.level 2) (s "[WARNING] " ...)))
             (fn mt.error [s ...] (when (<= s.level 3) (s "[ERROR] " ...)))
             (fn mt.error/nil [s ...] (s:error ...) nil)
             (fn mt.error/exit [s ...] (s:error ...) (os.exit false))
             (let [level (case (os.getenv :LOG_LEVEL)
                           (where n (not= nil (tonumber n))) (tonumber n)
                           (where s (= :string (type s)))
                           (if (s:match "^[Dd][Ee][Bb][Uu][Gg]$") 0
                               (s:match "^[Ii][Nn][Ff][Oo]$") 1
                               (s:match "^[Ww][Aa][Rr][Nn]$") 2
                               (s:match "^[Ww][Aa][Rr][Nn][Ii][Nn][Gg]$") 2
                               (s:match "^[Ee][Rr][Rr][Oo][Rr]$") 3
                               (error (.. "Invalid LOG_LEVEL: " s))))]
               (setmetatable {: level} mt))))


(local json {})

(fn json.null? [x]
  (or (= nil x)
      (= "" x)
      (= cjson.null x))) ; #<userdata NULL>

(fn json.file->decoded [path]
  (case (file->string path)
    str (cjson.decode str)
    (_ msg) (values nil msg)))

(fn json.format [str]
  "Use jq to format and sort keys in JSON string."
  (let [path (os.tmpname)
        with-cleanup #(do (os.remove path) $...)]
    (case-try (string->file str path)
      true (case (io.popen (.. "jq -SM . '" path "' 2>/dev/null"))
             file (with-open [file file] (file:read :*a))
             (_ msg) (values nil msg))
      str (with-cleanup str)
      (catch (_ msg) (with-cleanup (values nil msg)))))) 

(fn json.decoded->file [val path]
  (case (cjson.encode val)
    str (string->file (json.format str) path)
    (_ msg) (values nil msg)))

(fn json.decoded->file/exit [val path]
  (case (json.decoded->file val path)
    true (os.exit)
    (_ msg) (log:error/exit "Failed to write '" path "': " msg)))


(local http {})

(fn http.get [uri ?header]
  (assert/type :string uri)
  (assert/?type :table ?header)
  (let [uri (if (uri:match "^https?://") uri (.. "https://" uri))
        request (http/request.new_from_uri uri)]
    (when (not= nil ?header)
      (each [k v (pairs ?header)]
        (request.headers:append k v)))
    (case-try (request:go)
      (header stream) (stream:get_body_as_string)
      (where body (= (header:get ":status") :200)) (values body header)
      (catch _ (values nil (.. "Failed to get contents from " uri)))))) 


(fn timestamp->date [timestamp]
  (assert/type :string timestamp)
  (case (timestamp:match "^%d%d%d%d%-%d%d%-%d%d")
    date date
    _ (error "Failed to convert timestamp to date")))


(local nix {})

(fn nix.prefetch-url [url]
  (with-open [pipe (io.popen (.. "nix-prefetch-url " url " 2>/dev/null"))]
    (let [out (pipe:read :*a)]
      (if (not= "" out)
          (pick-values 1 (out:gsub "\n+" ""))
          (values nil "Failed to run nix-prefetch-url")))))


(macro with-cache [{: expire : path} & body]
  (let [alive? (if (= expire nil)
                   `(fn [] true)
                   `(fn [time#] (< (os.time) (+ time# ,expire))))]
    `(let [cache# (json.file->decoded ,path)]
       (if (and (not (json.null? cache#)) (,alive? cache#.time))
           cache#
           (let [out# (do ,(unpack body))]
             (case (json.decoded->file out# ,path)
               true out#
               (_# msg#) (error msg#)))))))


(local hub {:site "missing.hub"
            :token_ {:env "MISSING_TOKEN"}
            :uri-base "api.missing-hub.com/"
            :cache-dir "data/cache/"})

(fn hub.token [self]
  (if self.token_.missing?
      nil
      (or self.token_.cache
          (case (os.getenv self.token_.env)
            token (do (set self.token_.cache token)
                      token)
            _ (do (log:warn "Missing " self.token_.env)
                  (set self.token_.missing? true)
                  nil)))))

(fn hub.query [self path]
  (assert/type :string path)
  (let [token (self:token)
        request-header {:content-type "application/json"
                        :authorization (when token (.. "token " token))}]
    (case (http.get (.. self.uri-base path) request-header) 
      (body response-header) (values (cjson.decode body) response-header)
      (_ msg) (values nil msg))))

(fn hub.repo-cache-path [self owner repo]
  (assert/type :string owner)
  (assert/type :string repo)
  (.. self.cache-dir "site=" self.site "/owner=" owner "/repo=" repo "/info.json"))

(fn hub.latest-commit-cache-path [self owner repo ?ref]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/?type :string ?ref)
  (.. self.cache-dir "site=" self.site "/owner=" owner "/repo=" repo "/refs/"
      (if ?ref (.. ?ref ".json") "default.json")))

(fn hub.repo-query []
  (error "Override hub.repo-query!"))

(fn hub.latest-commit-query []
  (error "Override hub.latest-commit-query!"))

(fn hub.preprocess/repo []
  (error "Override hub.preprocess/repo!"))

(fn hub.preprocess/latest-commit []
  (error "Override hub.preprocess/latest-commit!"))

(fn hub.tarball-uri []
  (error "Override hub.tarball-uri!"))

(fn hub.repo [self {: owner : repo}]
  (assert/type :string owner)
  (assert/type :string repo)
  (log:info "Get " self.site " repo: " owner "/" repo)
  (with-cache {:path (self:repo-cache-path owner repo)
               :expire (* 8 60 60)}
    (log:debug "Cache " self.site " repo: " owner "/" repo)
    (case (self:query (self.repo-query owner repo))
      data (doto (self.preprocess/repo data)
             (tset :time (os.time)))
      (_ msg) (log:error/nil msg))))

(fn hub.tarball [self {: owner : repo : rev}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/?type :string rev)
  (log:info "Update: " self.site "/" owner "/" repo)
  (let [url (self.tarball-uri owner repo rev)]
    (case (nix.prefetch-url url)
      sha256 {: url : sha256}
      (_ msg) (log:error/nil (.. "Failed to get tarball hash: " msg)))))

(fn hub.known-commit [self {: owner : repo}]
  (assert/type :string owner)
  (assert/type :string repo)
  (let [key (.. self.site :/ owner :/ repo)
        {: date : rev : url : sha256} (or (. self.data key) {})]
    {: date : rev : url : sha256}))

(fn hub.latest-commit [self {: owner : repo : ref}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/?type :string ref)
  (log:info "Get " self.site " latest commit: " owner "/" repo
            (unpack (if ref ["/" ref] [])))
  (with-cache {:path (self:latest-commit-cache-path owner repo ref)
               :expire (* 8 60 60)}
    (log:debug "Cache " self.site " latest commit: " owner "/" repo
               (unpack (if ref ["/" ref] [])))
    (let [known (self:known-commit {: owner : repo})]
      (case (self:query (self.latest-commit-query owner repo ref))
        latest (let [latest (self.preprocess/latest-commit latest)]
                 (if (= known.rev latest.rev)
                     (doto known
                       (tset :time (os.time)))
                     (case (self:tarball {: owner : repo :rev latest.rev})
                       {: url : sha256} (doto latest
                                          (tset :time (os.time))
                                          (tset :url url)
                                          (tset :sha256 sha256))
                       _ known)))
        (_ msg) (log:error/nil msg)))))

(fn hub.package [self {: owner : repo : ref}]
  (let [known (doto (clone (let [key (.. self.site "/" owner "/" repo)]
                             (or (. self.data key) {})))
                ;; Could be removed in the latest data.
                (tset :description nil)
                (tset :homepage nil)
                (tset :license nil))]
    (case-try (self:repo {: owner : repo})
      repo_ (self:latest-commit {: owner : repo :ref (or ref repo_.default_branch)})
      latest (doto (merge! known repo_ latest)
               (tset :default_branch nil)
               (tset :time nil)
               (tset :timestamp nil)
               (tset :date (if latest.timestamp
                               (timestamp->date latest.timestamp)
                               latest.date)))
      (catch _ nil))))


(local github (let [self {:site :github.com
                          :token_ {:env "GITHUB_TOKEN"}
                          :uri-base "api.github.com/"}]
                (setmetatable self {:__index hub})))

(fn github.repo-query [owner repo]
  (.. "repos/" owner "/" repo))

(fn github.latest-commit-query [owner repo ref]
  (.. "repos/" owner "/" repo "/commits/" ref))

(fn github.tarball-uri [owner repo rev]
  (.. "https://github.com/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn github.preprocess/repo
  [{: default_branch : description : homepage : license}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (unless (json.null? homepage) homepage)
   :license (unless (json.null? license) license.spdx_id)})

(fn github.preprocess/latest-commit [{: sha : commit}]
  {:rev sha :timestamp commit.committer.date})


(local gitlab (let [self {:site :gitlab.com
                          :token_ {:env "GITLAB_TOKEN"}
                          :uri-base "gitlab.com/api/v4/"}]
                (setmetatable self {:__index hub})))

(fn gitlab.repo-query [owner repo]
  (.. "projects/" owner "%2F" repo))

(fn gitlab.latest-commit-query [owner repo ref]
  (.. "projects/" owner "%2F" repo "/repository/branches/" ref))

(fn gitlab.tarball-uri [owner repo rev]
  (.. "https://gitlab.com/" owner "/" repo "/-/archive/" rev ".tar.gz"))

(fn gitlab.preprocess/repo
  [{: default_branch : description : web_url}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (unless (json.null? web_url) web_url)})

(fn gitlab.preprocess/latest-commit [{: commit}]
  {:rev commit.id :timestamp commit.committed_date})


(local sourcehut (let [self {:site :git.sr.ht
                             :token_ {:env "SOURCEHUT_TOKEN"}
                             :uri-base "git.sr.ht/api/"}]
                   (setmetatable self {:__index hub})))

(fn sourcehut.repo-query [owner repo]
  (.. owner "/repos/" repo))

(fn sourcehut.latest-commit-query [owner repo]
  (.. owner "/repos/" repo "/log"))

(fn sourcehut.tarball-uri [owner repo rev]
  (.. "https://git.sr.ht/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn sourcehut.preprocess/repo [{: description : owner : name}]
  {:description (unless (json.null? description) description)
   :homepage (.. "https://git.sr.ht/" owner.canonical_name "/" name)})

(fn sourcehut.preprocess/latest-commit [{: results}]
  (let [commit (. results 1)]
    {:rev commit.id :timestamp commit.timestamp}))


(local codeberg (let [self {:site :codeberg.org
                            :token_ {:env "CODEBERG_TOKEN"}
                            :uri-base "codeberg.org/api/v1/"}]
                  (setmetatable self {:__index hub})))

(fn codeberg.repo-query [owner repo]
  (.. "repos/" owner "/" repo))

(fn codeberg.latest-commit-query [owner repo ref]
  (.. "repos/" owner "/" repo "/branches/" ref))

(fn codeberg.tarball-uri [owner repo rev]
  (.. "https://codeberg.org/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn codeberg.preprocess/repo
  [{: default_branch : description : html_url : website}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (or (unless (json.null? website) website)
                 (unless (json.null? html_url) html_url))})

(fn codeberg.preprocess/latest-commit [{: commit}]
  {:rev commit.id :timestamp commit.timestamp})


(local *packages* {:path "data/unstable-packages.json"
                   :data {}})

(fn *packages*.init! [self]
  (set hub.data self.data)
  (case (json.file->decoded self.path)
    pkgs (each [_ pkg (ipairs pkgs)]
          (let [{: site : owner : repo} pkg
                key (.. site "/" owner "/" repo)]
            (tset self.data key pkg)))
    _ (log:error/exit "Failed to load packages")))

(*packages*:init!)
(-> (icollect [_ pkg (stablepairs *packages*.data)]
      (case pkg.site
        :github.com (github:package pkg)
        :gitlab.com (gitlab:package pkg)
        (where (or :sr.ht :git.sr.ht)) (sourcehut:package pkg)
        :codeberg.org (codeberg:package pkg)
        _ {}))
    (json.decoded->file/exit *packages*.path))

;; vim: lw+=unless
