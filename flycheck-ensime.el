;;; flycheck-ensime.el --- ensime for flycheck -*- lexical-binding: t -*-

;; Author: ncaq <ncaq@ncaq.net>
;; Version: 0.1.1
;; Package-Requires: ((emacs "26")(ensime "2.0.0")(flycheck "31"))
;; URL: https://github.com/ncaq/flycheck-ensime

;; MIT License
;;
;; Copyright (c) 2018 ncaq
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

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
