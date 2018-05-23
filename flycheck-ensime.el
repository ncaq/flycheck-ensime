;; -*- lexical-binding: t -*-

(require 'ensime)
(require 'flycheck)
(require 'pcase)

(defun flycheck-ensime-start (checker cont)
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
