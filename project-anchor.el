;;; project-anchor.el --- Yet Another Project management system

;; Copyright (C) 2012 Andrew Hobson <ahobson@gmail.com>

;; Licensed under the same terms as GNU Emacs.

;; Keywords: project
;; Created: 26 Feb 2012
;; Author: Andrew Hobson <ahobson@gmail.com>
;; Version: 1

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; A framework for defining a project anchor that can be used by other
;; systems for searching files, providing buffer completion, etc.


(defvar project-anchor-find-hook nil
  "List of functions to be called to determine if a directory is a project anchor.")

(defvar project-anchor-files '(".git")
  "List of files used by project-anchor-find-by-file.")

(defun project-anchor-find-from-default-directory ()
  "Use project-anchor-find from default-directory."
  (project-anchor-find default-directory))

(defun project-anchor-find (file)
  "Look up the directory hierarchy from FILE calling
project-anchor-find-hook on each directory.  Return the directory
when one of the hooks returns true.  Return nil otherwise."
  ;; based on locate-dominating-file
  (setq file (abbreviate-file-name file))
  (let ((root nil)
        try)
    (while (not (or root
                    (null file)
                    (string-match locate-dominating-stop-dir-regexp file)))
      (setq try (run-hook-with-args-until-success 'project-anchor-find-hook file))
      (cond (try (setq root file))
            ((equal file (setq file (file-name-directory
                                     (directory-file-name file))))
             (setq file nil))))
    root))

(defun project-anchor-find-by-file (dir)
  "Does one of project-anchor-files exist in dir."
  (some (lambda (f) (file-exists-p (expand-file-name f dir))) project-anchor-files))

(defun project-anchor-find-with-mark (dir)
  "Does dir exist in a dired buffer with a mark. Returns dir if true, nil otherwise."
  (find (expand-file-name dir) (apply #'append
                     (remove-if 'null (mapcar 'project-anchor-get-buffer-marks (buffer-list))))
        :test 'equal))

(defun project-anchor-get-buffer-marks (buffer)
  "Get buffer marks from the provided buffer.  Return nil if not dired-mode."
  (save-excursion
    (set-buffer buffer)
    (if (eq 'dired-mode major-mode)
        (dired-get-marked-files))))

(provide 'project-anchor)
