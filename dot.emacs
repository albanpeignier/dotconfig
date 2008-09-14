(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(display-battery-mode nil)
 '(display-time-mode nil)
 '(global-font-lock-mode t)
 '(show-paren-mode nil)
 '(tab-width 2))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "#efebe7" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 135 :width normal :family "misc-fixed")))))

(add-to-list 'load-path 
						 "~/.emacs.d")

(set-terminal-coding-system 'latin-1)
(set-keyboard-coding-system 'latin-1)
(set-language-environment 'latin-1)

;;
;; utf-8
;;
(setq locale-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; yasnippet
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/snippets")

;; rspec-mode
(require 'rspec-mode)

;; 'text-mate' mode
(load "my-textmate")