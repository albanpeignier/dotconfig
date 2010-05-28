
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(global-font-lock-mode t)
 '(indent-tabs-mode nil)
 '(jde-jdk (quote ("1.6.0_07")))
 '(jde-jdk-registry (quote (("1.6.0_07" . "/usr/lib/jvm/java-6-sun") ("1.5.0_16" . "/usr/lib/jvm/java-1.5.0-sun"))))
 '(paren-match-face (quote paren-face-match-light))
 '(paren-sexp-mode t)
 '(safe-local-variable-values (quote ((encoding . utf-8))))
 '(save-place t nil (saveplace))
 '(scroll-bar-mode nil)
 '(tab-width 2)
 '(toggle-mapping-style (quote rspec)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "#efebe7" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 100 :width normal :foundry "unknown" :family "Inconsolata")))))

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

;; toggle
(require 'toggle)

(add-hook 'ruby-mode-hook
 (lambda ()
 (define-key ruby-mode-map (kbd "C-x t") 'toggle-buffer)))


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

(put 'downcase-region 'disabled nil)

(setq mumamo-chunk-coloring 'submode-colored)
(setq nxhtml-skip-welcome t)
(setq indent-region-mode t)
(setq nxhtml-default-encoding "utf8")

(custom-set-faces
'(mumamo-background-chunk-major ((((class color) (min-colors 88) (background dark)) (:background "black"))))
'(mumamo-background-chunk-submode1 ((((class color) (min-colors 88) (background dark)) (:background "#0A0A0A"))))
'(mumamo-background-chunk-submode2 ((((class color) (min-colors 88) (background dark)) (:background "#0A0A0A"))))
'(mumamo-background-chunk-submode3 ((((class color) (min-colors 88) (background dark)) (:background "#0A0A0A"))))
'(mumamo-background-chunk-submode4 ((((class color) (min-colors 88) (background dark)) (:background "#0A0A0A")))))

(load "~/.emacs.d/nxhtml/autostart.el")


(add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-nxhtml-mumamo)) 

;;(setq
;;      nxhtml-global-minor-mode t
;;      mumamo-chunk-coloring 'submode-colored
;;      nxhtml-skip-welcome t
;;      indent-region-mode t
;;      rng-nxml-auto-validate-flag nil
;;      nxml-degraded t)
;;(add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-nxhtml-mumamo))

(autoload 'feature-mode "feature-mode" "Mode for editing cucumber files" t)
(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

(add-to-list 'auto-mode-alist '("\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))

(require 'textile-mode)
(add-to-list 'auto-mode-alist '("\\.textile\\'" . textile-mode))

;(require 'wikipedia-mode)
(autoload 'wikipedia-mode "wikipedia-mode.el" "Major mode for editing documents in Wikipedia markup." t)

;; 'text-mate' mode
(load "my-textmate")
;;(require 'textmate)
(textmate-pair-mode)

;; Originally from stevey, adapted to support moving to a new directory.
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive
   (progn
     (if (not (buffer-file-name))
         (error "Buffer '%s' is not visiting a file!" (buffer-name)))
     (list (read-file-name (format "Rename %s to: " (file-name-nondirectory
                                                     (buffer-file-name)))))))
  (if (equal new-name "")
      (error "Aborted rename"))
  (setq new-name (if (file-directory-p new-name)
                     (expand-file-name (file-name-nondirectory
                                        (buffer-file-name))
                                       new-name)
                   (expand-file-name new-name)))
  ;; If the file isn't saved yet, skip the file rename, but still update the
  ;; buffer name and visited file.
  (if (file-exists-p (buffer-file-name))
      (rename-file (buffer-file-name) new-name 1))
  (let ((was-modified (buffer-modified-p)))
    ;; This also renames the buffer, and works with uniquify
    (set-visited-file-name new-name)
    (if was-modified
        (save-buffer)
      ;; Clear buffer-modified flag caused by set-visited-file-name
      (set-buffer-modified-p nil))
  (message "Renamed to %s." new-name)))

(defun switch-full-screen ()
  (interactive)
  (shell-command (concat "wmctrl -i -r " (frame-parameter nil 'outer-window-id) " -btoggle,fullscreen")))