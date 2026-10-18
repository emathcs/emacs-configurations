;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Appearance
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Bars
;;
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;
;; Line and column
;;
(column-number-mode 1)
(global-display-line-numbers-mode 1)

;;
;; Cursor
;;
(setq-default cursor-type 'bar)

;;
;; Buffers
;;
(setq inhibit-startup-screen t)
(add-hook 'emacs-startup-hook 'delete-other-windows)

;;
;; Header line instead tabbar
;;
(set-face-bold 'header-line t)
(set-face-background 'header-line "#555555")
(set-face-foreground 'header-line "#ffffff")

;;
;; Save
;;
(setq-default header-line-format
  '(" "
    (:eval (propertize
            (if buffer-file-name
                (file-name-nondirectory buffer-file-name)
              (buffer-name))
            'face 'mode-line-buffer-id))
    ;; Space
    " "
    (:eval (when (buffer-modified-p) (propertize "◉" 'face 'warning)))
    ;; Space
    " "
    (:eval (when buffer-read-only (propertize "RO" 'face 'shadow))))
  )

;;
;; Font configuration
;;
(if (eq system-type 'gnu/linux)
    (progn
      (message "Linux")
      (add-to-list 'default-frame-alist '(font . "Monospace-11")))
  (if (eq system-type 'darwin)
      (progn
        (message "macOS")
        (set-face-attribute 'default nil :font "Menlo-13"))))

;;
;; GUI screen configuration
;;
(when (window-system)
  (if (< (display-pixel-width) 1513)
      (progn
        (message "Laptop")
        ;; Code for Thinkpad X260
        (set-frame-position (selected-frame) 0 0)
        (add-to-list 'default-frame-alist '(width . 89))
        (add-to-list 'default-frame-alist '(height . 26))
        (add-to-list 'default-frame-alist '(fullscreen . maximized))
        (define-key global-map [f10] 'toggle-frame-maximized))
    (message "Monitor")
    ;; 24" monitor
    (set-frame-position (selected-frame) 656 0)
    (add-to-list 'default-frame-alist '(width . 236))
    (add-to-list 'default-frame-alist '(height . 87))))

;;
;; Theme
;;
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'leon t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Functionality
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Undo actions
;;
(cua-mode t)

;;
;; Control key
;;
(if (eq system-type 'darwin)
    (progn
      (message "macOS")
      (setq mac-command-modifier 'control)))

;;
;; Copy and paste with mouse
;;
(global-set-key [mouse-3] 'mouse-yank-primary)
;; After copy Ctrl+c in X11 apps, you can paste by `yank' in emacs
(setq x-select-enable-clipboard t)
;; After mouse selection in X11, you can paste by `yank' in emacs
(setq x-select-enable-primary t)

;;
;; New line and indentation
;;
(define-key global-map (kbd "RET") 'newline-and-indent)

;;
;; Removing extra lines
;;
(defun xah-clean-empty-lines (&optional *begin *end *n)
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (when (not *begin)
    (setq *begin (point-min) *end (point-max)))
  (save-excursion
    (save-restriction
      (narrow-to-region *begin *end)
      (progn
        (goto-char (point-min))
        (while (re-search-forward "\n\n\n+" nil "NOERROR")
          (replace-match (make-string (if *n *n 2) 10)))))))

(defun remove-spaces-and-lines ()
  ;; Removing extra spaces at the end of line
  (whitespace-cleanup)
  (xah-clean-empty-lines))

(add-hook 'before-save-hook 'remove-spaces-and-lines)

;;
;; Autocomplete pair
;;
(electric-pair-mode 1)
(defun my/electric-pair-newline-and-indent ()
  "Insert a newline, indent it, and reindent the closing delimiter if present"
  (interactive)
  (newline-and-indent)
  ;; If the next character is a closing delimiter, reindent that line too
  (save-excursion
    (forward-line 1)
    (when (looking-at "^[ \t]*\\s)")
      (indent-according-to-mode))))

(define-key global-map (kbd "RET") 'my/electric-pair-newline-and-indent)

;;
;; Elpa repository
;;
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(package-initialize)

;;
;; Web mode
;;
(defun web-mode-hook ()
  ;; Spaces
  (setq tab-width 4)
  ;; CSS and JS
  (setq web-mode-style-padding  4)
  (setq web-mode-script-padding 4)
  ;; Close tag
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-auto-close-style 2))

(add-hook 'web-mode-hook  'web-mode-hook)

(add-to-list 'auto-mode-alist '("\\.js\\'"    . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'"    . web-mode))
(add-to-list 'auto-mode-alist '("\\.ejs\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.xml\\'"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.twig\\'"  . web-mode))
(add-to-list 'auto-mode-alist '("\\.less\\'"  . web-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'"  . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.email\\'" . web-mode))

;;
;; C and C++
;;
(require 'cc-mode)
(setq-default c-basic-offset 4 indent-tabs-mode nil)
(c-set-offset 'access-label '0)

;;
;; \LaTeX
;;
(setq latex-run-command "pdflatex")
(setq TeX-PDF-mode t)
(setq TeX-show-compilation nil)

;;
;; Suggestions
;;
(global-corfu-mode 1)
(setq corfu-auto t)
(setq corfu-cycle t)
(setq corfu-auto-delay 0)
(setq corfu-auto-prefix 1)

(defun my/buffer-token-capf ()
  ;; Complete tokens like site-custom from the current buffer
  (let* ((chars "-A-Za-z0-9_")
         (beg (save-excursion (skip-chars-backward chars) (point)))
         (end (save-excursion (skip-chars-forward  chars) (point))))
    (when (< beg end)
      (list beg end
            (completion-table-dynamic
             (lambda (_prefix)
               (let (cands)
                 (save-excursion
                   (goto-char (point-min))
                   (while (re-search-forward "\\b[-A-Za-z0-9_]+\\b" nil t)
                     (push (match-string 0) cands)))
                 (delete-dups cands))))
            :exclusive 'no))))

;; Enable where you write markup/code
(dolist (hook '(web-mode-hook php-mode-hook prog-mode-hook text-mode-hook))
  (add-hook hook (lambda ()
                   (add-hook 'completion-at-point-functions #'my/buffer-token-capf nil t))))

;; Popup navigation
(define-key corfu-map (kbd "TAB") #'corfu-next)
(define-key corfu-map (kbd "<tab>") #'corfu-next)
(define-key corfu-map (kbd "S-TAB") #'corfu-previous)
(define-key corfu-map (kbd "<backtab>") #'corfu-previous)

;; Insert the suggestion
(define-key corfu-map (kbd "RET") #'corfu-insert)
(define-key corfu-map (kbd "<return>") #'corfu-insert)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; End of configurations
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
