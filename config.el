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

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "FuraCode Nerd Font" :size 16))

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

;;;; taking notes with org.
(use-package! org-noter
  :custom
  (org-noter-notes-search-path
   (list (expand-file-name (concat org-directory "Notes")))))

;;;; brainstorming with org
(use-package! org-brain
  :init
  (setq org-brain-path (concat org-directory "Brain"))
  :config
  (evil-set-initial-state 'org-brain-visualize-mode 'emacs)
  :after org-noter
  (add-to-list 'org-noter-notes-search-path org-brain-path t))

;;;; org mode journal
(use-package! org-journal
  :custom
  (org-journal-dir (expand-file-name (concat org-directory "Journal")))
  :after org
  (add-to-list 'org-agenda-files org-journal-dir t))

;;;; org agenda
(use-package! org-super-agenda
  :custom
  (org-super-agenda-mode t))

;;;; evil mode everywhere
(use-package! evil-collection
  :custom
  (evil-collection-setup-minibuffer nil)
  (evil-undo-system 'undo-fu))

;;;; format files with lsp if possible
(use-package! lsp-mode
  :defer t
  :config
  (setq lsp-log-io nil)
  (setq lsp-ui-peek-mode t)
  (setq +format-with-lsp t))

(use-package! lsp-ui
  :defer t
  :config
  ;; sideline diagnostics buggin.
  (setq lsp-ui-sideline-show-diagnostics nil)
  ;; doom disables lsp-ui-doc by default
  (setq lsp-ui-doc-enable nil)
  ;; Don't show symbol definitions in the sideline. They are pretty noisy,
  ;; and there is a bug preventing Flycheck errors from being shown (the
  ;; errors flash briefly and then disappear).
  (setq lsp-ui-sideline-update-mode nil))

;;;; mu email indexer
(use-package! mu4e
  :config
  (setq mail-user-agent 'mu4e-user-agent)
  (setq +mu4e-backend 'mbsync)
  (setq +mu4e-workspace-name "email")
  (setq mu4e-maildir xdg-mail-home)
  (setq mu4e-attachment-dir "~/Downloads/Attachments"))

;;; vimrc syntax
(use-package! vimrc-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.vim\\(rc\\)?\\'" . vimrc-mode)))

;;;; uml in emacs
(use-package! plantuml-mode
  :config
  (setq plantuml-executable-path "/usr/bin/plantuml")
  (setq plantuml-default-exec-mode 'executable))

;;;; elcord
(use-package! elcord)

;;;; leetcode
(use-package! leetcode
  :config
  (setq leetcode-prefer-language "python3")
  (setq leetcode-prefer-sql "mysql"))

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
