;;; flycheck-ensime.el --- ensime for flycheck -*- lexical-binding: t -*-

;; Author: ncaq <ncaq@ncaq.net>
;; Version: 0.1.0
;; Package-Requires: ((emacs "26")(ensime "2.0.0")(flycheck "32-cvs"))
;; URL: https://github.com/ncaq/flycheck-ensime

;;; Commentary:

;; display ensime error message for flycheck buffer.

;;; Code:

(require 'ensime)
(require 'flycheck)
(require 'pcase)

(defun flycheck-ensime-start (checker cont)
  "This function mapping ensime to flycheck.
Argument CHECKER syntax checker being started.
Argument CONT callback."
  (funcall cont 'finished
           (mapcar
            (lambda (note)
              (flycheck-error-new-at
               (plist-get note :line)
               (plist-get note :col)
               (pcase (plist-get note :severity)
                 ('error 'error)
                 ('warn 'warning)
                 (_ 'info))
               (plist-get note :msg)
               :checker checker
               :filename (plist-get note :file)
               ))
            (ensime-all-notes))))

;;;###autoload
(flycheck-define-generic-checker 'ensime
  "A Scala (Java) checker using ENSIME."
  :start 'flycheck-ensime-start
  :modes '(scala-mode java-mode)
  :predicate 'ensime-connection-or-nil)

;;;###autoload
(add-to-list 'flycheck-checkers 'ensime)

(provide 'flycheck-ensime)

;;; flycheck-ensime.el ends here
