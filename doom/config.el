;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(use-package! f)

(defun load-doom-dir-file (rel-path)
  (load-file (f-join doom-user-dir rel-path)))

(setq local-config-modules
      '("config.ui.el"
        "config.org.el"))

(dolist (rel-path local-config-modules)
  (load-doom-dir-file rel-path))
