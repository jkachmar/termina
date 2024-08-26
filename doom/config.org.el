;;; config.org.el -*- lexical-binding: t; -*-

(setq org-directory "~/org/")

(defvar local/org-roam-subdir "roam"
  "Subdirectory of org-directory to use for org-roam.")
(defvar local/org-lit-subdir "lit"
  "Subdirectory of org-roam-directory to use for literature notes.")

(setq local/org-roam-dir (f-join org-directory local/org-roam-subdir))
(setq local/org-lit-dir (f-join local/org-roam-dir local/org-lit-subdir))

(setq org-roam-directory local/org-roam-dir)

(setq org-agenda-files (list org-directory
                             local/org-roam-dir
                             (f-join local/org-roam-dir "daily")))

(setq org-default-notes-file (f-join org-roam-directory "inbox.org"))
(setq +org-capture-notes-file org-default-notes-file)
(setq org-clock-continuously nil
      org-clock-persist t)

(after! org
  (org-clock-persistence-insinuate))

(use-package! org-roam
  :config
  (add-hook 'org-roam-mode-hook #'turn-on-visual-line-mode)
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?" :target
           (file+head "%<%Y%m%d%H%M%S>.org" "#+title: ${title}\n")
           :unnarrowed t)))
  (setq org-roam-dailies-directory "daily/"))
