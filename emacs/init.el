(defun load-config()
  (interactive)
  (org-babel-load-file "~/.emacs.d/config.org"))

;;Initialize all packages, I do this in init.el so as not to break compatibility with org-latex-preview, at some point in the future this should be fixed though
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("ELPA" . "http://tromey.com/elpa/") 
                          ("gnu" . "http://elpa.gnu.org/packages/")
                          ("marmalade" . "http://marmalade-repo.org/packages/")))

(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t )
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t )
(add-to-list 'load-path "~/.emacs.d/themes/")

;;Load modified version of org-mode if not installed
(unless (package-installed-p 'org-mode-from-vc) ;; Check if *your* named package is installed
  (message "Attempting to install org-mode from VC repository...")
  ;; Use 'org-mode' as the package name in the spec as the repo is likely for 'org-mode'
  (package-vc-install '(org-mode-from-vc :url "https://git.tecosaur.net/tec/org-mode" :branch "dev"))
  (message "Finished package-vc-install for org-mode."))

(package-initialize)
;;load org-mode that is compatible with org-latex-preview here, so that the native org-mode does not get loaded when calling babel-load file
(use-package org
  ;; Ensure it doesn't try to install from ELPA/MELPA.
  ;; You installed it via package-vc-install.
  :ensure nil
  ;; IMPORTANT: Point to the 'lisp' directory of your VC-installed Org.
  :load-path "~/.emacs.d/elpa/org-mode-from-vc/lisp/"


 :config
  (setq org-latex-preview-scale 1.5)
  (org-latex-preview-auto-mode 1)
  )

(use-package org-latex-preview
  :after org
  :config
  (add-hook 'org-mode-hook #'org-latex-preview-auto-mode)
  (add-hook 'org-mode-hook #'turn-on-org-cdlatex)
(setq org-latex-packages-alist
       '(("" "amsmath" t)  ;; <--- ADDED AMATH HERE
         ("" "tikz" t)
         ("" "tikz-cd" t)))

  ;(add-hook 'org-mode-hook #'org-toggle-pretty-entities)
  (setq org-latex-preview-live t)

  (setq org-latex-preview-auto-generate 'live)

  (message "org-latex-preview loaded and auto mode enabled"))

;;If/once org-latex-preview is integrated in usual org-mode, one should be able to move the above config back to config.org
  (load-config)



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("da75eceab6bea9298e04ce5b4b07349f8c02da305734f7c0c8c6af7b5eaa9738"
     "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e"
     "2721b06afaf1769ef63f942bf3e977f208f517b187f2526f0e57c1bd4a000350"
     "9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14"
     "7c28419e963b04bf7ad14f3d8f6655c078de75e4944843ef9522dbecfcd8717d"
     default))
 '(package-selected-packages nil)
 '(package-vc-selected-packages
   '((org-mode-from-vc :url "https://git.tecosaur.net/tec/org-mode"
		       :branch "dev")))
 '(warning-suppress-log-types '((use-package))))
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
