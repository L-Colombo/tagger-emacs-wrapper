;;; tagger.el --- Interact with tags in your org files -*- lexical-binding:t -*-

;; Copyright (C) 2025 Lorenzo Colombo

;; Author: Lorenzo Colomvo
;; Version: 0.1.0
;; Keywords: Org-Mode, Tagger
;; URL: https://github.com/L-Colombo/tagger-emacs-wrapper

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This packages provides wrappers around the "tagger" command line tool
;; (https://github.com/L-Colombo/tagger) The aim of "tagger" is to provide
;; an easy and faster way to interact (list, search and refile) with tags in your .org files.

;;; Code:

(defvar tagger/tagger-directory
  nil
  "If provided, offers a completing read of files in your org directory")

;;;###autoload
(defun tagger/locate ()
  "Show files that contain tags matching a given pattern"
  (interactive)
  (let ((pattern (read-from-minibuffer "Query pattern: ")))
    (let ((file-list (string-split (shell-command-to-string
                                    (format "tgr locate %s" pattern))))
          (link-buf-name (format "%s.org" pattern))
          (header
           (format "* Files containing tags that match the pattern \"%s\"\n" pattern)))
      (with-current-buffer
          (get-buffer-create link-buf-name)
        (insert header)
        (dolist (file file-list)
          (insert (format "[[%s][%s]]\n"
                          (format "%s/%s" tagger/tagger-directory file) file)))
        (beginning-of-buffer)
        (org-mode)
        (org-fold-show-all)
        (switch-to-buffer-other-window link-buf-name)))))

;;;###autoload
(defun tagger/refile ()
  "Refile all subtrees that match a given pattern"
  (interactive)
  (let ((pattern (read-from-minibuffer "Query pattern: ")))
    (let ((refiled-file-contents (shell-command-to-string
                                  (format "tgr refile %s --no-pager" pattern)))
          (refiled-bufname (format "tgr_refiled_%s.org" pattern)))
      (with-current-buffer
          (get-buffer-create refiled-bufname)
        (insert refiled-file-contents)
        (beginning-of-buffer)
        (org-mode)
        (switch-to-buffer-other-window refiled-bufname)))))

;;;###autoload
(defun tagger/search ()
  "Search for tags in your tagger directory"
  (interactive)
  (let ((pattern (read-from-minibuffer "Query pattern: ")))
    (let ((search-output (shell-command-to-string
                          (concat "tgr search " pattern))))

      (if (= 1 (length search-output))
          (message (format "No result for query \"%s\"" pattern))
        (with-current-buffer-window
            (get-buffer-create (format "*tgr search: %s*" pattern))
            nil nil
          (insert search-output)
          (switch-to-buffer-other-window (format "*tgr search: %s*" pattern)))))))

;;;###autoload
(defun tagger/tags-all ()
  "Get a quick view of all the tags in your tagger directory"
  (interactive)
  (let ((tags (shell-command-to-string "tgr tags")))
    (with-current-buffer-window
        (get-buffer-create "*All tags*")
        nil nil
      (insert tags)
      (switch-to-buffer-other-window "*All tags*"))))

;;;###autoload
(defun tagger/tags-file ()
  "Get all your tags in a specific file withing your tagger directory"
  (interactive)
  (let ((file (completing-read
               "Where? "
               (directory-files
                tagger/tagger-directory))))
    (with-current-buffer-window
        (get-buffer-create (format "*Tags in %s*" file))
        nil nil
      (insert (shell-command-to-string (format "tgr tags --file=%s" file)))
      (switch-to-buffer-other-window (format "*Tags in %s*" file)))))

(provide 'tagger)

;;; tagger.el ends here
