(load "textmate")

(setq emacs-lisp-mode-ignores
      '(?\'))
(setq lisp-interaction-mode-ignores emacs-lisp-mode-ignores)

(defun switch-to-textmate-pair-mode ()
  (if (member major-mode '(ruby-mode rspec-mode))
      (textmate-pair-mode t)))

(add-hook 'after-change-major-mode-hook 'switch-to-textmate-pair-mode)
(add-hook 'ruby-mode-hook 'switch-to-textmate-pair-mode)
