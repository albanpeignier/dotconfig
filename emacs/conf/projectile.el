(require 'projectile)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(projectile-mode +1)

(setq projectile-enable-caching t)

; (setq projectile-indexing-method 'alien)
(setq projectile-project-search-path '("~/Projects/"))
