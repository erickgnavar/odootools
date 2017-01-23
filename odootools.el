;;; odootools.el --- Odoo tools for development

;; Copyright © 2017 Erick Navarro

;; Author: Erick Navarro <erick@navarro.io>
;;; Commentary:
;; Find Odoo security groups and views

;;; Code:

(require 'f)

(require 'helm)

(defvar odootools-addons-path "")

(defconst odootools--groups-db (f-join odootools-addons-path ".groups"))

(defconst odootools--views-db (f-join odootools-addons-path ".views"))

(defconst odootools--analyzer-path (concat (file-name-directory load-file-name) "analyzer.py"))

(defun odootools--read-groups-db ()
  "Read groups db."
  (let ((data (f-read-text odootools--groups-db)))
    (split-string data "\n")))

(defun odootools--read-views-db ()
  "Read views db."
  (let ((data (f-read-text odootools--views-db)))
    (split-string data "\n")))

(defun odootools--build-db ()
  "Analyze files in odoo addons path."
  (if (f-exists? odootools-addons-path)
      (shell-command (format "python %s %s" odootools--analyzer-path odootools-addons-path))
    (message "Please setup the Odoo addons path variable")))

;; HELM functions

(defun odootools--insert-group-id (candidate)
  "Insert group ID selected as CANDIDATE."
  (let ((group-id (car (cdr (split-string candidate ";")))))
    (insert group-id)))

(defun odootools--insert-view-id (candidate)
  "Insert view ID selected as CANDIDATE."
  (let ((view-id (car (cdr (split-string candidate ";")))))
    (insert view-id)))

(defun odootools--open-view-file (candidate)
  "Open buffer with selected file as CANDIDATE."
  (let ((path (car (split-string candidate ";"))))
    (find-file-existing path)))

(defun odootools--group-transformer (candidate)
  "Format candidate as CANDIDATE."
  (let ((splited (split-string candidate ";")))
    (let ((name (car splited))
          (group-id (car (cdr splited))))
      (format "%s:%s" name group-id))))

(defun odootools--view-transformer (candidate)
  "Format candidate as CANDIDATE."
  (message candidate)
  (let ((splited (split-string candidate ";")))
    (let ((path (f-relative (car splited) odootools-addons-path))
          (view-id (car (cdr splited))))
      (format "%s:%s" path view-id))))

(defun odootools--groups-source ()
  "Group IDs source."
  (helm-build-sync-source "Security groups IDs"
    :candidates (lambda ()
                  (odootools--read-groups-db))
    :real-to-display 'odootools--group-transformer
    :action '(("Insert this group ID `C-c'" . odootools--insert-group-id))))

(defun odootools--views-source ()
  "View IDs source."
  (helm-build-sync-source "Views IDs"
    :candidates (lambda ()
                  (odootools--read-views-db))
    :real-to-display 'odootools--view-transformer
    :action '(("Insert this view ID `C-c'" . odootools--insert-view-id))))

(defun odootools--views-open-source ()
  "View IDs source."
  (helm-build-sync-source "Views"
    :candidates (lambda ()
                  (odootools--read-views-db))
    :real-to-display 'odootools--view-transformer
    :action '(("Open the view file `C-c'" . odootools--open-view-file))))

;; Public API

(defun odootools-rebuild-db ()
  "Rebuild the addons index."
  (interactive)
  (odootools--build-db))

(defun odootools-find-group-id ()
  "Find group ID."
  (interactive)
  (if (not (f-exists? odootools--groups-db))
      (odootools--build-db))
  (helm :sources (odootools--groups-source)
        :buffer "*helm for search group ID*"))

(defun odootools-find-view-id ()
  "Find view ID."
  (interactive)
  (if (not (f-exists? odootools--views-db))
      (odootools--build-db))
  (helm :sources (odootools--views-source)
        :buffer "*helm for search view ID*"))

(defun odootools-find-view-file ()
  "Find view file."
  (interactive)
  (if (not (f-exists? odootools--views-db))
      (odootools--build-db))
  (helm :sources (odootools--views-open-source)
        :buffer "*helm for search view file*"))

(provide 'odootools)

;;; odootools.el ends here
