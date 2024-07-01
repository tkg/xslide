;;;; xslide3.el --- XSL Integrated Development Environment
;; Copyright (C) 1998, 1999, 2000, 2001, 2003, 2011, 2013 Tony Graham

;; Author: Tony Graham <tkg@menteith.com>
;; Contributors: Simon Brooke, Girard Milmeister, Norman Walsh,
;;               Moritz Maass, Lassi Tuura, Simon Wright, KURODA Akira,
;;               Ville Skyttä, Glen Peterson
;; Created: 29 July 2011
;; Keywords: languages, xsl, xml

;;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; imenu stuff

(defun xsl-sort-alist (alist)
  "Sort an alist."
  (sort
   alist
   (lambda (a b) (string< (car a) (car b)))))

(defun xsl-imenu-create-index-function ()
  "Create an alist of elements, etc. suitable for use with `imenu'."
  (interactive)
  (let ((template-alist '())
	(mode-alist '())
	(key-alist '())
	(attribute-set-alist '())
	(name-alist '())
	(function-alist '())
	(accumulator-alist '())
	(xsl-mode-alist '()))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*<xsl:template\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 1))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      ;; Don't move point because the 'mode' attribute may be before
      ;; the 'match' attribute.
      (if (save-excursion
	    (re-search-forward
	     "match\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>" nil t)))
	     t))
	  (let* ((pattern (buffer-substring-no-properties
			   ;; Rely on the pattern that didn't match
			   ;; returning nil and on `or' evaluating the
			   ;; second form when the first returns nil.
			   (or
			    (match-beginning 2)
			    (match-beginning 3))
			   (or
			    (match-end 2)
			    (match-end 3))))
		 (pattern-position (or
				    (match-beginning 2)
				    (match-beginning 3))))
	    ;; Test to see if there is a 'mode' attribute.
	    ;; Match on either single-quoted or double-quoted attribute value.
	    ;; The expression that doesn't match will have return nil for
	    ;; `match-beginning' and `match-end'.
	    (if (save-excursion
		  (re-search-forward
		   "mode\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
		   (save-excursion
		     (save-match-data
		       (re-search-forward "<\\|>" nil t)))
		   t))
		(let* ((mode-name (buffer-substring-no-properties
				   ;; Rely on the pattern that didn't match
				   ;; returning nil and on `or' evaluating the
				   ;; second form when the first returns nil.
				   (or
				    (match-beginning 2)
				    (match-beginning 3))
				   (or
				    (match-end 2)
				    (match-end 3))))
		       (mode-name-alist (assoc mode-name mode-alist)))
		  (if mode-name-alist
		      (setcdr mode-name-alist
			      (list (car (cdr mode-name-alist))
				    (cons pattern pattern-position)))
		    (setq mode-alist
			  (cons
			   (list mode-name (cons pattern pattern-position))
			   mode-alist))))
	      (setq template-alist
		    (cons (cons pattern pattern-position)
			  template-alist)))))
      ;; When there's no "match" attribute, can still have "name"
      ;; attribute
      (if (save-excursion
	    (re-search-forward
	     "\\s-+name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>" nil t)))
	     t))
	  (setq name-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 name-alist))))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*<xsl:attribute-set\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 1))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      (if (save-excursion
	    (re-search-forward
	     "name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>$" nil t)))
	     t))
	  (setq attribute-set-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 attribute-set-alist))))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*<xsl:key\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 1))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      (if (save-excursion
	    (re-search-forward
	     "name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>$" nil t)))
	     t))
	  (setq key-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 key-alist))))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*<xsl:function\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 1))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      (if (save-excursion
	    (re-search-forward
	     "name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>$" nil t)))
	     t))
	  (setq function-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 function-alist))))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*<xsl:accumulator\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 1))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      (if (save-excursion
	    (re-search-forward
	     "name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>$" nil t)))
	     t))
	  (setq accumulator-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 accumulator-alist))))
    (goto-char (point-min))
    (while
	(re-search-forward
	 "^\\s-*\\(<xsl:mode\\)\\(\\s-+\\)" nil t)
      ;; Go to the beginning of the whitespace after the element name
      (goto-char (match-beginning 2))
      ;; Match on either single-quoted or double-quoted attribute value.
      ;; The expression that doesn't match will have return nil for
      ;; `match-beginning' and `match-end'.
      (if (save-excursion
	    (re-search-forward
	     "name\\s-*=\\s-*\\(\"\\([^\"]*\\)\"\\|'\\([^']*\\)'\\)"
	     (save-excursion
	       (save-match-data
		 (re-search-forward "<\\|>$" nil t)))
	     t))
	  (setq xsl-mode-alist
		(cons
		 (cons (buffer-substring-no-properties
			;; Rely on the pattern that didn't match
			;; returning nil and on `or' evaluating the
			;; second form when the first returns nil.
			(or
			 (match-beginning 2)
			 (match-beginning 3))
			(or
			 (match-end 2)
			 (match-end 3)))
		       (or
			(match-beginning 2)
			(match-beginning 3)))
		 xsl-mode-alist))
	(setq xsl-mode-alist
	      (cons
	       (cons "#unnamed" (point))
	       xsl-mode-alist))))
    (message "%S" accumulator-alist)
    (message "%S" xsl-mode-alist)
    (append
     (if key-alist
	 (list (cons "xsl:key" (xsl-sort-alist key-alist))))
     (if function-alist
	 (list (cons "xsl:function" (xsl-sort-alist function-alist))))
     (if accumulator-alist
	 (list (cons "xsl:accumulator" (xsl-sort-alist accumulator-alist))))
     (if attribute-set-alist
	 (list (cons "xsl:attribute-set"
		     (xsl-sort-alist attribute-set-alist))))
     (if xsl-mode-alist
	 (list (cons "xsl:mode"
		     (xsl-sort-alist xsl-mode-alist))))
     (if name-alist
	 (list (cons "name=" (xsl-sort-alist name-alist))))
     (if mode-alist
	 ;; Sort the mode-alist members, format the mode names nicely,
	 ;; and sort the templates within each mode.
	 (append
	  (mapcar (lambda (x)
		    (cons (format "mode=\"%s\"" (car x))
			  (xsl-sort-alist (cdr x))))
		  (xsl-sort-alist mode-alist))))
     (xsl-sort-alist template-alist))))




(define-derived-mode xsl-mode nxml-mode "xslide"
  "Major mode for editing XSLT."
  (setq rng-schema-locating-files
	(add-to-list 'rng-schema-locating-files
		     (locate-file "xslt-schemas.xml" load-path)))
  (rng-auto-set-schema)
  (setq imenu-create-index-function 'xsl-imenu-create-index-function)
  (setq imenu-extract-index-name-function 'xsl-imenu-create-index-function)
  (imenu-add-to-menubar "Templates")
  (make-local-variable 'tab-width)
  (setq tab-width 8)
  (setq indent-tabs-mode nil)
  (modify-syntax-entry ?' "."))

;;; xslide3.el ends here
