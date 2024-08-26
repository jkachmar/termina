;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).

(doom! :input
       :completion
       (corfu +orderless)
       (vertico +orderless +icons)

       :ui
       deft
       doom
       doom-dashboard
       ;
       hl-todo
       indent-guides
       ;;ligatures
       ;;minimap
       modeline
       ophints
       (popup +defaults)
       ;;tabs
       treemacs
       ;;unicode
       (vc-gutter +pretty)
       ;
       ;;window-select
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       ;;lispy
       multiple-cursors
       ;;objedt
       ;;parinfer
       ;;rotate-text
       snippets
       word-wrap

       :emacs
       (dired +icons +ranger)
       electric
       ibuffer
       undo 
       vc

       :term
       vterm

       :checkers
       (syntax +childframe)
       ;;(spell +flyspell)
       ;;grammar

       :tools
       ;;biblio
       ;;collab
       (debugger +lsp)
       direnv
       ;;editorconfig
       ;;ein
       (eval +overlay)
       lookup
       (lsp +eglot)
       magit 
       ;;make
       ;;pass
       ;;pdf
       ;;prodigy
       ;;terraform
       ;;tmux
       ;;tree-sitter
       ;;upload

       :os
       (:if (featurep :system 'macos) macos)
       ;;tty

       :lang
       ;;agda
       ;;beancount
       cc
       ;;clojure
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       data
       ;;(dart +flutter)
       ;;dhall
       ;;elixir
       ;;elm
       emacs-lisp        
       ;;erlang
       ;;ess
       ;;factor
       ;;faust
       ;;fortran
       ;;fsharp
       ;;fstar
       ;;gdscript
       ;;(go +lsp)
       ;;(graphql +lsp)
       ;;(haskell +lsp)
       ;;hy    
       ;;idris
       json
       ;;(java +lsp)
       ;;javascript
       ;;julia
       ;;kotlin
       ;;latex
       ;;lean
       ;;ledger
       ;;lua
       markdown
       ;;nim
       nix
       ;;ocaml
       (org +pretty
            +roam2
            +pomodoro
            )
       ;;php
       ;;plantuml
       ;;purescript
       ;;python
       ;;qt
       ;;racket
       ;;raku
       ;;rest
       ;;rst
       ;;(ruby +rails)
       ;;(rust +lsp)
       ;;scala
       ;;(scheme +guile)
       sh
       ;;sml
       ;;solidity
       ;;swift
       ;;terra
       web
       yaml
       ;;zig

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere
       ;;irc
       ;;(rss +org)

       :config
       ;;literate
       (default +bindings +smartparens))
