;; bootstrap straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq package-enable-at-startup nil)
(straight-use-package 'use-package)

;; general behavior
(setq ring-bell-function 'ignore) ;; silence
(add-to-list 'auto-mode-alist '("\\.sbclrc\\'" . lisp-mode))
(global-hl-line-mode 1)
(savehist-mode 1)
(defun find-init-el () (interactive) (find-file "~/.emacs.d/init.el"))
(bind-key* "M-m i" 'find-init-el)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setq whitespace-style '(face tabs trailing empty space-after-tab tab-mark missing-newline-at-eof))
(setq-default indent-tabs-mode nil)
(set-face-attribute 'default nil :family "Cascadia Code" :height 95)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq scroll-conservatively 20)
(setq scroll-margin 5)
(setq kill-whole-line t)
(scroll-bar-mode -1)

(use-package consult :straight t :config
  (global-set-key (kbd "<f1> t") 'consult-theme))

(setq enable-recursive-minibuffers t)

(use-package ivy :straight t
  :config
  (defun ivy-switch-buffer ()
  "Switch to another buffer."
  (interactive)
  (ivy-read "Switch to buffer: " #'internal-complete-buffer
            :keymap ivy-switch-buffer-map
            :preselect (buffer-name (current-buffer))
            :action #'ivy--switch-buffer-action
            :matcher #'ivy--switch-buffer-matcher
            :caller 'ivy-switch-buffer))
  (ivy-mode 1)
  (setq-default completing-read-function 'completing-read-default)
  (setq-default ivy-use-virtual-buffers t)
  (setq ivy-re-builders-alist '((t . orderless-ivy-re-builder))))

(use-package orderless :straight t
  :config
  (setq-default completion-styles '(orderless flex basic))
  (setq orderless-component-separator "[ &]"))

(use-package vertico :straight t
  :config
  (vertico-mode 1))

(defun copy-all-or-region ()
  (interactive)
  (if (use-region-p)
      (progn
        (kill-new (buffer-substring (region-beginning) (region-end)))
        (message "Copied selection.")
        (deactivate-mark))
    (progn
      (kill-new (buffer-string))
      (message "Copied buffer."))))

(global-set-key (kbd "M-w") 'copy-all-or-region)
(global-set-key (kbd "C-h") 'backward-delete-char-untabify)
(global-set-key (kbd "C-a") 'beginning-of-visual-line)
(global-set-key (kbd "C-e") 'end-of-visual-line)
(global-visual-line-mode 't)

(define-key prog-mode-map (kbd "M-R") 'replace-string)
(define-key prog-mode-map (kbd "C-M-r") 'replace-regexp)
(define-key prog-mode-map (kbd "M-n") 'forward-paragraph)
(define-key prog-mode-map (kbd "M-p") 'backward-paragraph)

(bind-key* "M-m b s" 'scratch-buffer)
(setq-default initial-major-mode 'lisp-interaction-mode)
(bind-key* "C-(" 'split-window-horizontally)
(bind-key* "C--" 'split-window-vertically)
(bind-key* "C-W" 'delete-window)
(bind-key* "C-w" 'kill-region)

(use-package winum :straight t)
(winum-mode)
(bind-key* "M-m w d" 'delete-window)
(bind-key* "M-m w /" 'split-window-horizontally)
(bind-key* "M-m w -" 'split-window-vertically)
(bind-key* "M-1" 'winum-select-window-1)
(bind-key* "M-2" 'winum-select-window-2)
(bind-key* "M-3" 'winum-select-window-3)
(bind-key* "M-4" 'winum-select-window-4)
(bind-key* "M-5" 'winum-select-window-5)

(bind-key* "C-x C-b" 'ivy-switch-buffer)
(bind-key* "M-m b b" 'ivy-switch-buffer)
(bind-key* "M-m M-b" 'ibuffer)
(bind-key* "M-m b d" 'kill-this-buffer)
(bind-key* "M-m b p" 'previous-buffer)
(bind-key* "M-m b n" 'next-buffer)
(bind-key* "M-m M-p" 'previous-buffer)
(bind-key* "M-m M-n" 'next-buffer)
(bind-key* "M-m M-d" 'kill-this-buffer)
(bind-key* "M-m b w" 'read-only-mode)

(bind-key* "C-M-p" 'backward-paragraph)
(bind-key* "C-M-n" 'forward-paragraph)

(use-package hideshow :straight t
  :config (add-hook 'prog-mode-hook 'hs-minor-mode))

(bind-key* "M-z" 'hs-hide-level)
(bind-key* "M-j" 'hs-show-block)
(bind-key* "C-M-j" 'hs-show-block)
(bind-key* "M-k" 'hs-toggle-hiding)

;; packages
(require 'subr-x)
(use-package alist :straight apel :demand t)

(use-package doom-themes :straight t)

(use-package company :straight t
  :config
  (setf company-backends '(company-capf company-files))
  (setq company-global-modes '(not org-mode))
  (global-company-mode 1))

(use-package paredit
  :straight t
  :config
  (define-key paredit-mode-map (kbd "C-j") nil)
  (define-key paredit-mode-map (kbd "C-m") nil)
  (define-key paredit-mode-map (kbd "C-h") 'paredit-backward-delete)
  (define-key paredit-mode-map (kbd "<backspace>") 'paredit-backward-delete)
  (define-advice paredit-kill (:around (fn &rest args) u-kill)
    (let* ((cur (point)) (bol (point-at-bol)) (eol (point-at-eol))
           (end (save-excursion (paredit-forward-sexps-to-kill cur eol) (point))))
      (if (and (eq cur bol)
               (not (eq ?\C-j (char-before (1- cur))))
               (eq ?\C-j (char-after end))
               (eq ?\C-j (char-after (1+ end))))
          (kill-region cur (1+ end)) (apply fn args))))
  (advice-add 'paredit-kill :after 'fixup-whitespace)
  (define-advice paredit-kill (:after (&rest _args) u-indent)
    (save-excursion (paredit-indent-sexps))))

(use-package paren-face :straight t)

(defun u-lisp-config ()
  (smartparens-mode -1)
  (paredit-mode t)
  (paren-face-mode t)
  (auto-highlight-symbol-mode 1)
  (setq-local tab-always-indent 'complete))

(defun u-minibuffer-setup ()
  (when (memq this-command '(eval-expression))
    (u-lisp-config)))

(add-hook 'minibuffer-setup-hook 'u-minibuffer-setup)
(add-hook 'lisp-mode-hook 'u-lisp-config)
(add-hook 'lisp-mode-hook 'whitespace-mode)
(add-hook 'emacs-lisp-mode-hook 'u-lisp-config)
(add-hook 'emacs-lisp-mode-hook 'whitespace-mode)
(add-hook 'inferior-scheme-mode-hook 'u-lisp-config)

(define-key emacs-lisp-mode-map (kbd "C-j") 'eval-print-last-sexp)

(use-package popup :straight t)
(use-package pyim
  :straight t
  :config
  (setq pyim-page-length 5)
  (pyim-default-scheme 'microsoft-shuangpin)
  (global-set-key (kbd "M-i") 'pyim-deactivate)
  (global-set-key (kbd "M-o") 'pyim-activate)
  (define-key pyim-mode-map "." #'pyim-next-page)
  (define-key pyim-mode-map "," #'pyim-previous-page)
  (setq-default pyim-punctuation-translate-p '(no))
  (setq-default pyim-pinyin-fuzzy-alist '())
  (setq-default pyim-enable-shortcode nil)
  (require 'popup)
  (setq pyim-page-tooltip 'popup))

(use-package pyim-basedict :straight t
  :config
  (pyim-basedict-enable))

(use-package vterm
  :straight t
  :bind
  (:map vterm-mode-map
   ("C-c C-j" . vterm-copy-mode)
   ("C-q" . vterm-send-next-key)
   ("C-k" . vterm-send-Ck)
   :map vterm-copy-mode-map
   ("C-c C-k" . (lambda () (interactive) (vterm-copy-mode -1))))
  :config
  (setq vterm-max-scrollback 1000000)
  (defun vterm-send-Ck ()
    "Send `C-k' to libvterm."
    (interactive)
    (kill-ring-save (point) (vterm-end-of-line))
    (vterm-send-key "k" nil nil t)))

(use-package multi-vterm
  :straight t
  :config
  (bind-key* (kbd "M-t M-t") 'multi-vterm) ;
  (bind-key* (kbd "M-t M-p") 'multi-vterm-prev)
  (bind-key* (kbd "M-t M-n") 'multi-vterm-next)
  (define-key vterm-mode-map (kbd "C-c C-j") 'vterm-copy-mode)
  (define-key vterm-copy-mode-map (kbd "C-c C-k") 'vterm-copy-mode))

(use-package auto-highlight-symbol :straight t
  :config
  (global-auto-highlight-symbol-mode 1)
  (setq ahs-idle-interval 0))

(use-package undo-tree :straight t
  :config
  (global-undo-tree-mode))

(use-package smartparens :straight t
  :config
  (add-hook 'prog-mode-hook 'smartparens-mode))

(use-package clang-format :straight t
  :config
  (setq-default clang-format-executable "/home/a/.venv/bin/clang-format")
  (defun save-and-format-buffer ()
    (interactive)
    (clang-format-buffer)
    (save-buffer))
  (add-hook 'c++-mode-hook
            (lambda () (local-set-key (kbd "C-x C-s") 'save-and-format-buffer))))

(use-package swiper
  :straight t
  :config
  (global-set-key (kbd "M-t") 'swiper-thing-at-point)
  (global-set-key (kbd "C-s") 'swiper-isearch)
  (global-set-key (kbd "C-r") 'swiper-isearch-backward))

(use-package slime-company :straight t)

(use-package slime
  :straight t
  :config
  (setq-default company-backends (cons 'company-slime (remove 'company-slime company-backends)))
  (setq-default inferior-lisp-program "sbcl")
  (slime-setup '(slime-company slime-fancy slime-quicklisp slime-asdf slime-media slime-parse slime-mrepl))
  (add-hook 'slime-mode-hook 'u-lisp-config)
  (add-hook 'slime-repl-mode-hook 'u-lisp-config)
  (bind-key* (kbd "M-t M-s") 'slime-repl)
  (define-key slime-mode-map (kbd "C-M-a") 'slime-beginning-of-defun)
  (define-key slime-mode-map (kbd "C-M-e") 'slime-end-of-defun)
  (define-key slime-mode-map (kbd "M-p") 'backward-paragraph)
  (define-key slime-mode-map (kbd "M-n") 'forward-paragraph)
  (define-key slime-mode-map (kbd "M-r") nil)
  (defun ora-slime-completion-in-region (_fn completions start end)
    (funcall completion-in-region-function start end completions))
  (advice-add
   'slime-display-or-scroll-completions
   :around #'ora-slime-completion-in-region)
  (setq-default
   inferior-lisp-program "sbcl"
   slime-lisp-implementations
   `((sbcl ("sbcl" "--dynamic-space-size" "4096"))
     (mega-sbcl ("sbcl" "--dynamic-space-size" "24000" "--control-stack-size" "2"))))
  )

(use-package slime-repl
  :bind (:map slime-repl-mode-map
              ("M-r")
              ("M-s")
              ("C-s" . consult-history)
              ("C-r" . consult-history))
  :config
    (set-alist 'consult-mode-histories 'slime-repl-mode '(slime-repl-input-history)))

(use-package telega :straight t
  :config
  (bind-key* "C-c C-t C-t" 'telega)
  (setq telega-avatar-workaround-gaps-for '(return t)))

(use-package org-download :straight t
  :ensure t
  :after org
  :config
  (setq-default
   org-download-image-dir "assets"
   ;; Basename setting seems to be simply ignored.
   org-download-screenshot-basename ".org.png"
   org-download-timestamp "org_%Y%m%d-%H%M%S_"
   org-download-heading-lvl nil)
  (defun paste-screenshot-to-telega ()
      (interactive)
    (shell-command-to-string
     (format org-download-screenshot-method
             org-download-screenshot-file))
    (let ((file  "/tmp/screenshot.png")
          (as-file-p current-prefix-arg))
      (telega-buffer-file-send
       file (telega-completing-read-chat
             (format "Send %s(%s) to chat: "
                     (cond ((listp file)
                            (format "%d FILES" (length file)))
                           (t "FILE"))
                     (if as-file-p
                         "as file"
                       "autodetect"))))))
  (global-set-key (kbd "C-M-y") 'paste-screenshot-to-telega)
  :custom
  (org-download-screenshot-method
   (cond
    ((eq system-type 'gnu/linux)
     "xclip -selection clipboard -t image/png -o > '%s'"))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("de8f2d8b64627535871495d6fe65b7d0070c4a1eb51550ce258cd240ff9394b0"
     "34cf3305b35e3a8132a0b1bdf2c67623bc2cb05b125f8d7d26bd51fd16d547ec"
     default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
