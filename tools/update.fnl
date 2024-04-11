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

(macro assert/type [typ x]
  `(when (not= ,typ (type ,x))
     (error (.. ,x " should be " ,typ ", got " (view ,x)))))

(macro assert/optional-type [typ x]
  `(when (and (not= nil ,x)
              (not= ,typ (type ,x)))
     (error (.. ,x " should be " ,typ ", got " (view ,x)))))

(macro assert/method [self x]
  `(when (not= :function (type (. ,self ,x)))
     (error "method '" ,x "' invalid or missing")))

(macro unless [condition & body]
  `(when (not ,condition) ,(unpack body)))

;;; ==========================================================================
;;; Logging utilities
;;; ==========================================================================

(fn %log [_ ...]
  (let [out io.stderr]
    (out:write "update.fnl: " ...)
    (out:write "\n")))

(local log (setmetatable {} {:__call %log}))

(fn log.warn [...]
  (let [out io.stderr]
    (out:write "update.fnl: [WARNING] " ...)
    (out:write "\n")))

(fn log.warn/nil [...]
  (log.warn ...)
  nil)

(fn log.error [...]
  (let [out io.stderr]
    (out:write "update.fnl: [ERROR] " ...)
    (out:write "\n")))

(fn log.error/nil [...]
  (log.error ...)
  nil)

(fn log.error/exit [...]
  (log.error ...)
  (os.exit false))

;;; ==========================================================================
;;; Table extras
;;; ==========================================================================

(fn merge! [left ...]
  (each [_ right (ipairs [...])]
    (each [k v (pairs right)]
      (tset left k v)))
  left)

;;; ==========================================================================
;;; File utilities
;;; ==========================================================================

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

;;; ==========================================================================
;;; JSON manipulation
;;; ==========================================================================

(local json {})

(fn json.null? [x]
  (or (= nil x)
      (= "" x)
      (= cjson.null x))) ; #<userdata NULL>

(fn json.file->object [path]
  (case (file->string path)
    str (cjson.decode str)
    (_ msg) (values nil msg)))

(fn json.file->jq [path]
  (case (io.popen (.. "jq -SM . '" path "' 2>/dev/null"))
    file (with-open [file file] (file:read :*a))
    (_ msg) (values nil msg)))

(fn json.format [str]
  "Use jq to format and sort keys in JSON string."
  (let [path (os.tmpname)]
    (case-try (string->file str path)
      true (json.file->jq path)
      str (do
            (os.remove path)
            str)
      (catch (_ msg) (do
                       (os.remove path)
                       (values nil msg))))))

(fn json.object->file [obj path]
  (case (cjson.encode obj)
    str (string->file (json.format str) path)
    (_ msg) (values nil msg)))

(fn json.object->file/exit [obj path]
  (case (json.object->file obj path)
    true (os.exit)
    (_ msg) (log.error/exit "failed to write '" path "': " msg)))

;;; ==========================================================================
;;; HTTP access
;;; ==========================================================================

(local http {})

(fn http.get [uri ?headers]
  (when (not= :string (type uri))
    (error "uri string expected, got " (view uri)))
  (when (and (not= nil ?headers)
             (not= :table (type ?headers)))
    (error (.. "header should be table, while got: " (view ?headers))))
  (let [uri (if (uri:match "^https?://")
                uri
                (.. "https://" uri))
        request (http/request.new_from_uri uri)]
    (when (not= nil ?headers)
      (each [k v (pairs ?headers)]
        (request.headers:append k v)))
    (case-try (request:go)
      (headers stream) (stream:get_body_as_string)
      (where body (= (headers:get ":status") :200))
      (values body headers)
      (catch _ (values nil (.. "failed to get contents from " uri)))))) 

;;; ==========================================================================
;;; Nix helpers
;;; ==========================================================================

(local nix {})

(fn nix.prefetch-url [url]
  (with-open [pipe (io.popen (.. "nix-prefetch-url " url " 2>/dev/null"))]
    (let [out (pipe:read :*a)]
      (if (not= "" out)
          (pick-values 1 (out:gsub "\n+" ""))
          (values nil "failed to run nix-prefetch-url")))))

;;; ==========================================================================
;;; GitHub, GitLab, etc. meta table
;;; ==========================================================================

(local hub {:site "missing.hub"
            :token {:env-var "MISSING_TOKEN"}
            :get-uri-base "api.missing-hub.com/"})

(fn hub.get-token [self]
  (if self.token.missing?
      nil
      (or self.token.cache
          (case (os.getenv self.token.env-var)
            token (do
                    (set self.token.cache token)
                    token)
            _ (do
                (log.warn (.. "missing " self.token.env-var))
                (set self.token.missing? true)
                nil)))))

(fn hub.get [self query ?token]
  (assert/type :string query)
  (assert/optional-type :string ?token)
  (let [token (or ?token (self:get-token))
        request-headers
        {:content-type "application/json"
         :authorization (when token (.. "token " token))}]
    (case (http.get (.. self.get-uri-base query) request-headers) 
      (body headers) (values (cjson.decode body) headers)
      (_ msg) (values nil msg))))

(fn hub.repo-info-cache-path [self owner repo]
  (assert/type :string owner)
  (assert/type :string repo)
  (.. "data/cache/site=" self.site "/owner=" owner "/repo=" repo "/info.json"))

(fn hub.latest-commit-info-cache-path [self owner repo ?ref]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/optional-type :string ?ref)
  (.. "data/cache/site=" self.site "/owner=" owner "/repo=" repo "/refs/"
      (if ?ref (.. ?ref ".json") "default.json")))

(fn hub.query-repo-info [self {: owner : repo}]
  (assert/method self :repo-info-uri-path)
  (assert/method self :preprocess/repo-info)
  (case (self:get (self.repo-info-uri-path owner repo))
    info (let [info (self.preprocess/repo-info info)
               cache-path (self:repo-info-cache-path owner repo)]
           (set info.time (os.time))
           (case (json.object->file info cache-path)
             true info
             (_ msg) (error msg)))
    (_ msg) (log.error/nil msg)))

(fn too-old? [time ?hours]
  (assert/optional-type :number ?hours)
  (case (type time)
    :number (let [hours (or ?hours 23)]
              (< time (- (os.time) (* hours 60 60))))
    _ true))

(fn hub.get-repo-info [self {: owner : repo}]
  (assert/type :string owner)
  (assert/type :string repo)
  (let [cache-path (self:repo-info-cache-path owner repo)
        cache (json.file->object cache-path)]
    (if (and cache (not (too-old? cache.time (- (* 7 24) 1))))
        cache
        (do
          (log "query " self.site " repo: " owner "/" repo)
          (self:query-repo-info {: owner : repo})))))

(fn hub.get-latest-commit-info [self {: owner : repo : ref}]
  (assert/type :string owner)
  (assert/type :string repo)
  (assert/optional-type :string ref)
  (assert/method self :latest-commit-info-uri-path)
  (assert/method self :preprocess/latest-commit-info)
  (assert/method self :tarball-uri)
  (let [cache-path (self:latest-commit-info-cache-path owner repo ref)
        cache (json.file->object cache-path)]
    (if (and cache (not (too-old? cache.time)))
        cache
        (do
          (log "query " self.site " latest commit: " owner "/" repo
               (unpack (if ref ["/" ref] [])))
          (case (self:get (self.latest-commit-info-uri-path owner repo ref))
            info (let [info (self.preprocess/latest-commit-info info)]
                   (if (and cache (= cache.rev info.rev))
                       (let [cache (doto cache
                                     (tset :time (os.time)))]
                         (case (json.object->file cache cache-path)
                           true cache
                           (_ msg) (error msg)))
                       (let [url (self.tarball-uri owner repo info.rev)]
                         (log "update sha256 hash: " owner "/" repo
                              (unpack (if ref ["/" ref] [])))
                         (case (nix.prefetch-url url) 
                           sha256 (let [info (doto info
                                               (tset :url url)
                                               (tset :sha256 sha256)
                                               (tset :time (os.time)))]
                                    (case (json.object->file info cache-path)
                                      true info
                                      (_ msg) (error msg)))
                           (_ msg) (log.error/nil msg)))))
            (_ msg) (log.error/nil msg))))))

(fn timestamp->date [timestamp]
  (assert/type :string timestamp)
  (case (timestamp:match "^%d%d%d%d%-%d%d%-%d%d")
    date date
    _ (error "failed to convert timestamp to date")))

(fn hub.get-all-info [self {: owner : repo : ref}]
  (case-try (self:get-repo-info {: owner : repo})
    repo-info
    (self:get-latest-commit-info {: owner : repo
                                  :ref (or ref repo-info.default_branch)})
    latest-commit-info
    (doto (merge! repo-info latest-commit-info)
      (tset :default_branch nil)
      (tset :time nil)
      (tset :timestamp nil)
      (tset :date (timestamp->date latest-commit-info.timestamp)))
    (catch _ nil)))

;;; ==========================================================================
;;; GitHub query
;;; ==========================================================================

(local github (let [self {:site :github.com
                          :token {:env-var "GITHUB_TOKEN"}
                          :get-uri-base "api.github.com/"}]
                (setmetatable self {:__index hub})))

(fn github.repo-info-uri-path [owner repo]
  (.. "repos/" owner "/" repo))

(fn github.latest-commit-info-uri-path [owner repo ref]
  (.. "repos/" owner "/" repo "/commits/" ref))

(fn github.tarball-uri [owner repo rev]
  (.. "https://github.com/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn github.preprocess/repo-info
  [{: default_branch : description : homepage : license}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (unless (json.null? homepage) homepage)
   :license (unless (json.null? license) license.spdx_id)})

(fn github.preprocess/latest-commit-info [{: sha : commit}]
  {:rev sha :timestamp commit.committer.date})

;;; ==========================================================================
;;; GitLab query
;;; ==========================================================================

(local gitlab (let [self {:site :gitlab.com
                          :token {:env-var "GITLAB_TOKEN"}
                          :get-uri-base "gitlab.com/api/v4/"}]
                (setmetatable self {:__index hub})))

(fn gitlab.repo-info-uri-path [owner repo]
  (.. "projects/" owner "%2F" repo))

(fn gitlab.latest-commit-info-uri-path [owner repo ref]
  (.. "projects/" owner "%2F" repo "/repository/branches/" ref))

(fn gitlab.tarball-uri [owner repo rev]
  (.. "https://gitlab.com/" owner "/" repo "/-/archive/" rev ".tar.gz"))

(fn gitlab.preprocess/repo-info
  [{: default_branch : description : web_url}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (unless (json.null? web_url) web_url)})

(fn gitlab.preprocess/latest-commit-info [{: commit}]
  {:rev commit.id :timestamp commit.committed_date})

;;; ==========================================================================
;;; SourceHut query
;;; ==========================================================================

(local sourcehut (let [self {:site :git.sr.ht
                             :token {:env-var "SOURCEHUT_TOKEN"}
                             :get-uri-base "git.sr.ht/api/"}]
                   (setmetatable self {:__index hub})))

(fn sourcehut.repo-info-uri-path [owner repo]
  (.. owner "/repos/" repo))

(fn sourcehut.latest-commit-info-uri-path [owner repo]
  (.. owner "/repos/" repo "/log"))

(fn sourcehut.tarball-uri [owner repo rev]
  (.. "https://git.sr.ht/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn sourcehut.preprocess/repo-info [{: description}]
  {:description (unless (json.null? description) description)})

(fn sourcehut.preprocess/latest-commit-info [{: results}]
  (let [commit (. results 1)]
    {:rev commit.id :timestamp commit.timestamp}))

;;; ==========================================================================
;;; Codeberg query
;;; ==========================================================================

(local codeberg (let [self {:site :codeberg.org
                            :token {:env-var "CODEBERG_TOKEN"}
                            :get-uri-base "codeberg.org/api/v1/"}]
                  (setmetatable self {:__index hub})))

(fn codeberg.repo-info-uri-path [owner repo]
  (.. "repos/" owner "/" repo))

(fn codeberg.latest-commit-info-uri-path [owner repo ref]
  (.. "repos/" owner "/" repo "/branches/" ref))

(fn codeberg.tarball-uri [owner repo rev]
  (.. "https://codeberg.org/" owner "/" repo "/archive/" rev ".tar.gz"))

(fn codeberg.preprocess/repo-info
  [{: default_branch : description : html_url : website}]
  {: default_branch
   :description (unless (json.null? description) description)
   :homepage (or (unless (json.null? website) website)
                 (unless (json.null? html_url) html_url))})

(fn codeberg.preprocess/latest-commit-info [{: commit}]
  {:rev commit.id :timestamp commit.timestamp})

;;; ==========================================================================
;;; Main
;;; ==========================================================================

(case (json.file->object "data/unstable-packages.json")
  packages (-> (icollect [_ package (stablepairs packages)]
                 (doto package
                   (merge! (case package.site
                             :github.com
                             (github:get-all-info package)
                             :gitlab.com
                             (gitlab:get-all-info package)
                             (where (or :sr.ht :git.sr.ht))
                             (sourcehut:get-all-info package)
                             :codeberg.org
                             (codeberg:get-all-info package)
                             _ {}))))
               (json.object->file/exit "data/unstable-packages.json"))
  _ (log.error/exit "failed to import data/unstable-packages.json"))

;; vim: lw+=unless
