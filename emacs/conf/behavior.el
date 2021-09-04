(setq create-lockfiles nil)
(global-auto-revert-mode 1)

(cua-mode 1)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq indent-region-mode t)

(setq-default indent-tabs-mode nil)

(setq tab-width 2) ; or any other preferred value
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)

(setq auto-save-list-file-prefix nil)

(setq-default display-buffer-reuse-frames t)
