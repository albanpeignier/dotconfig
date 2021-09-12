(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(package-initialize) ;; You might already have this line

; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

(setq package-list
      '(yafolding ace-window yasnippet-classic-snippets flymake-go flymake-ruby coffee-mode f flx ghub git-gutter inf-ruby inflections json-snatcher magit-popup ov robe rspec-mode string-inflection treepy yaml-mode async projectile projectile-rails feature-mode copy-as-format csv-mode itail rainbow-mode abyss-theme dockerfile-mode magit bundler coverage duplicate-thing json-reformat json-mode twilight-theme go-mode yasnippet flx-ido haml-mode slim-mode scss-mode markdown-mode))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(defun load-directory (dir)
  (let ((load-it (lambda (f) (load-file (concat (file-name-as-directory dir) f)))))
	  (mapc load-it (directory-files dir nil "\\.el$"))))

(load-directory "~/.emacs.d/conf/")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(markdown-mode yasnippet-classic-snippets yaml-mode yafolding twilight-theme string-inflection slim-mode scss-mode rspec-mode robe rainbow-mode projectile-rails magit-popup magit json-mode itail haml-mode go-mode git-gutter ghub flymake-ruby flymake-go flx-ido feature-mode duplicate-thing dockerfile-mode csv-mode coverage copy-as-format coffee-mode bundler async ace-window abyss-theme))
 '(tab-width 2)
 '(tramp-default-method "ssh" t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
