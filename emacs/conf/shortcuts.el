(set-terminal-coding-system 'latin-1)
(set-keyboard-coding-system 'latin-1)
(set-language-environment 'latin-1)

(global-set-key [f1]     'delete-other-windows)
(global-set-key [\C-f1]  'delete-window)
(global-set-key [f2]     'split-window-vertically)
(global-set-key [f3]     'split-window-horizontally)

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

(defun font-size-reset ()
  (interactive)
  (set-face-attribute 'default nil :height 140))

(global-set-key (kbd "C-+") 'font-size-increase)
(global-set-key (kbd "C-=") 'font-size-decrease)

(global-unset-key "\^z") ; disables "ctrl-z"
