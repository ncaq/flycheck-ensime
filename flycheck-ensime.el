;;; flycheck-ensime.el --- ensime for flycheck -*- lexical-binding: t -*-

;; Author: ncaq <ncaq@ncaq.net>
;; Version: 0.1.1
;; Package-Requires: ((emacs "26")(ensime "2.0.0")(flycheck "31"))
;; URL: https://github.com/ncaq/flycheck-ensime

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

;; display ensime error message for flycheck buffer.

;;; Code:

(require 'ensime)
(require 'flycheck)
(require 'pcase)

;;;###autoload
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
(with-eval-after-load 'flycheck
  (with-eval-after-load 'ensime
    (flycheck-define-generic-checker 'ensime
      "A Scala (Java) checker using ENSIME."
      :start 'flycheck-ensime-start
      :modes '(scala-mode java-mode)
      :predicate 'ensime-connection-or-nil)
    (add-to-list 'flycheck-checkers 'ensime)
    ))

(provide 'flycheck-ensime)

;;; flycheck-ensime.el ends here
