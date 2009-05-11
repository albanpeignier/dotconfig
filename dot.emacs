
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(autotest-command "nice -19 autotest -f")
 '(global-font-lock-mode t)
 '(indent-tabs-mode nil)
 '(jde-jdk (quote ("1.6.0_07")))
 '(jde-jdk-registry (quote (("1.6.0_07" . "/usr/lib/jvm/java-6-sun") ("1.5.0_16" . "/usr/lib/jvm/java-1.5.0-sun"))))
 '(paren-match-face (quote paren-face-match-light))
 '(paren-sexp-mode t)
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(tab-width 2)
 '(toggle-mapping-style (quote rspec)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "#efebe7" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 72 :width normal :foundry "unknown" :family "Monaco")))))

(add-to-list 'load-path 
						 "~/.emacs.d")

(server-start)

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

;; autotest
(require 'autotest)

;; toggle
(require 'toggle)

(add-hook 'ruby-mode-hook
 (lambda ()
 (define-key ruby-mode-map (kbd "C-x t") 'toggle-buffer)))


;; 'text-mate' mode
(load "my-textmate")

;; (add-to-list 'default-frame-alist '(font . "-ttf-monaco-medium-r-normal-regular-0-0-0-0-m-0-iso8859-1"))

;; load ido
(require 'ido)
(ido-mode t)

;; Desktop Management
(desktop-save-mode 1)

;; Twilight Theme
(require 'color-theme)
; (color-theme-initialize)
(load-file "~/.emacs.d/color-theme-twilight.el")
(color-theme-twilight)

;; Puppet Mode
(require 'puppet-mode)

;; Midnight
(require 'midnight)

;; Rcov-mode
(require 'rcov)

(global-set-key [f1]  'delete-other-windows)
(global-set-key [\C-f1]     'delete-window)
(global-set-key [f2]     'split-window-vertically)
(global-set-key [f3]     'split-window-horizontally)

;; emacs-rails
;(add-to-list 'load-path 
;						 "~/.emacs.d/rails")
;(require 'rails)

(require 'git)

;; Disable toolbar and menu
(tool-bar-mode -1)
(menu-bar-mode -1)

;; Configure spell .. use ispell-buffer
(require 'ispell)

;; Change font size

(defun font-size-increase ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (ceiling (* 1.10
                                  (face-attribute 'default :height)))))
(defun font-size-decrease ()
  (interactive)
  (set-face-attribute 'default
                      nil
                      :height
                      (floor (* 0.9
                                  (face-attribute 'default :height)))))

(global-set-key (kbd "C-+") 'font-size-increase)
(global-set-key (kbd "C-=") 'font-size-decrease)
