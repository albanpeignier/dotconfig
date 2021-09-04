(add-hook 'before-save-hook 'gofmt-before-save)
(setq gofmt-command "~/Projects/go/bin/goimports")

(defun local-go-mode-hook ()
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build && go test"))
  ; Godef jump key binding
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
)
(add-hook 'go-mode-hook 'local-go-mode-hook)

;(eval-after-load "go-mode" '(require 'flymake-go))

(setenv "GOPATH" "/home/alban/Projects/go")
