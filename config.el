;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
;;; Code:
(setq user-full-name "Idigo Luwum"
      user-mail-address "luwum@pm.me")

(setq xdg-config-home (cond
                       ((getenv "XDG_CONFIG_HOME") (file-name-as-directory (getenv "XDG_CONFIG_HOME")))
                       ((file-name-as-directory (expand-file-name "~/.config")))))

(setq xdg-data-home (cond
                     ((getenv "XDG_DATA_HOME") (file-name-as-directory (getenv "XDG_DATA_HOME")))
                     ((file-name-as-directory (expand-file-name "~/.local/share")))))

(setq xdg-bin-home (cond
                    ((getenv "XDG_BIN_HOME") (file-name-as-directory (getenv "XDG_BIN_HOME")))
                    ((file-name-as-directory (expand-file-name "~/.local/bin")))))

(setq xdg-mail-home (cond
                     ((getenv "XDG_MAIL_HOME") (file-name-as-directory (getenv "XDG_MAIL_HOME")))
                     ((file-name-as-directory (expand-file-name "~/.local/mail")))))

(setq xdg-var-home (cond
                    ((getenv "XDG_VAR_HOME") (file-name-as-directory (getenv "XDG_VAR_HOME")))
                    ((file-name-as-directory (expand-file-name "~/.local/var")))))

(defun insert-file-contents-as-string (file)
  "The return the contents of FILE as a string" ()
  (when (file-readable-p file)
    (with-temp-buffer
      (insert-file-contents file)
      (buffer-string))))

;;  Python
;; (when (featurep! :lang python)
;;   (remove-hook! 'python-mode-hook #'(pipenv-mode))
;;   (map! :desc "poetry"
;;         :prefix "C-p"))

;; (map! (:when (featurep! :lang python +poetry))
;;       :leader
;;       :map python-mode-map
;;       :desc "poetry run"
;;       :prefix "C-p"
;;       :g "r" #'poetry-run)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "FuraMono Nerd Font Mono" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory (file-name-as-directory "~/Documents"))

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
;;
;; disable auto saving.
(setq auto-save-default nil)

;;;; org mode
(use-package! org
  :init
  (setq org-id-locations-file (substitute-env-in-file-name "$XDG_DATA_HOME/org/orgids"))
  :custom
  ;; org-todo
  (org-todo-keywords '("TODO(t!)"
                       "IN-PROGRESS(p!)"
                       "WAITING(w!)"
                       "|"
                       "DONE(d!)"))

  ;; org-agenda
  ;; A single org agenda file is stored in $XDG_DATA_HOME. This file contains
  ;; the list of all org files that will included in the 'org-agenda-menu'
  (org-agenda-files (directory-files-recursively
                     "~/Documents/"
                     "\.org$"
                     t))

  (org-tag-alist nil)
  (org-tag-alist-for-agenda '(("@personal" . ?p)
                              ("@tech" . ?t)
                              ("@social" . ?s)
                              ("@work" . ?w)))
  (org-tag-groups-alist nil)
  (org-tag-groups-alist-for-agenda '(("@personal" . ?p)
                                     ("@tech" . ?t)
                                     ("@social" . ?s)
                                     ("@work" . ?w ))))

;;;; taking pdf annotations with org.
(use-package! org-noter
  :defer-incrementally
  org evil-org org-brain
  :init
  (setq org-noter-notes-search-path
   (list (expand-file-name (concat org-directory "Notes")))))

;;;; brainstorming with org
(use-package! org-brain
  :defer-incrementally
  org evil-org org-noter org-journal
  :after-call
  org-noter-doc-mode-hook
  org-noter-notes-mode-hook
  :config
  (setq org-brain-path
   (expand-file-name (concat org-directory "Brain")))
  (evil-set-initial-state 'org-brain-visualize-mode 'emacs))

(after! :and org-brain org-noter
 (add-to-list 'org-noter-notes-search-path org-brain-path 'append))

;;;; org mode journal
(use-package! org-journal
  :defer-incrementally
  org evil-org org-noter org-brain org-agenda org-super-agenda
  :after-call
  org-agenda-mode-hook
  :config
  (setq org-journal-dir (expand-file-name (concat org-directory "Journal"))))

(after! org-journal
  (add-to-list 'org-agenda-files org-journal-dir 'append))

;;;; org agenda
(use-package! org-super-agenda
  :defer-incrementally
  org org-agenda evil-org
  :after-call
  org-agenda-mode-hook
  :config
  (org-super-agenda-mode t))

;;;; evil mode everywhere
(use-package! evil-collection
  :after evil
  :custom
  (evil-collection-setup-minibuffer t)
  :init
  (evil-collection-init))

;;;; language server protcol
(use-package! lsp-mode
  :custom
  ;; doom disables lsp-ui-doc by default
  (lsp-ui-doc-enable nil)
  (lsp-ui-peek-mode t)
  (lsp-log-io nil)
  (+format-with-lsp t))

(use-package! lsp-ui
  :custom
  ;; sideline diagnostics buggin.
  (lsp-ui-sideline-show-diagnostics nil)
  ;; Don't show symbol definitions in the sideline. They are pretty noisy,
  ;; and there is a bug preventing Flycheck errors from being shown (the
  ;; errors flash briefly and then disappear).
  (lsp-ui-sideline-update-mode nil))

;;;; mu email indexer
(use-package! mu4e
  :init
  (setq +mu4e-workspace-name "mail")
  (setq mu4e-maildir xdg-mail-home)
  :custom
  (mail-user-agent 'mu4e-user-agent)
  (mu4e-attachment-dir "~/Downloads/Attachments")
  (+mu4e-backend 'mbsync))

(use-package! vimrc-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.vim\\(rc\\)?\\'" . vimrc-mode)))
;;;; uml in emacs
(use-package! plantuml-mode
  :custom
  (plantuml-executable-path "/usr/bin/plantuml")
  (plantuml-default-exec-mode 'executable))

;;;; elcord
(use-package! elcord)

;;;; leetcode
(use-package! leetcode
  :custom
  (leetcode-prefer-language "python3")
  (leetcode-prefer-sql "mysql"))

;; Python
(use-package! poetry
  :config
  (setq poetry-tracking-strategy 'projectile))

;;  (use-package! spotify
;;  :config
;;  (setq spotify-oauth2-client-id (s-trim (insert-file-contents-as-string
;;                                  (concat xdg-data-home "spotify/emacs-id"))))
;;  (setq spotify-oauth2-client-secret (s-trim (insert-file-contents-as-string
;;                                      (concat xdg-data-home "spotify/emacs-secret"))))
;;  (setq spotify-transport 'connect)
;;  (spotify-remote-mode t))
;;  (map! "C-c ." #'spotify-mode)
;;; config.el ends here
