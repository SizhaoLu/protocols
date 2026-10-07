(require 'ox-publish)
(require 'ox-html)
(require 'subr-x)

;; Allow per-page layout control with:
;;   #+PAGE_LAYOUT: wide
;; Supported values: default, wide
(add-to-list 'org-export-options-alist
             '(:page-layout "PAGE_LAYOUT" nil "default" t))

(defconst site-root "/protocols"
  "Root URL of this GitHub Pages site.")

(defun site-html-head ()
  "Shared <head> additions for all exported pages."
  (concat
   "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n"
   "<link rel=\"stylesheet\" href=\"" site-root "/style.css\" type=\"text/css\" />"))

(defun site-html-preamble (_info)
  "Shared site header."
  (format
   (concat
    "<header class=\"site-header\">"
    "<div class=\"site-header-inner\">"
    "<a class=\"site-title\" href=\"%s/\">Protocols</a>"
    "<nav class=\"site-nav\" aria-label=\"Primary\">"
    "<a href=\"%s/protocols/\">Protocols</a>"
    "<a href=\"%s/snippets/\">Snippets</a>"
    "</nav>"
    "</div>"
    "</header>")
   site-root site-root site-root))

(defun site-html-postamble (_info)
  "Shared footer."
  "<footer class=\"site-footer\"><p>Last built: %T</p></footer>")

(defun site-html-filter-final-output (output backend info)
  "Apply site-specific HTML enhancements to OUTPUT.

Tables are wrapped in a horizontally scrollable container. Pages that
contain a table get a wider content class automatically. PAGE_LAYOUT=wide
adds an explicit extra-wide layout class."
  (if (not (org-export-derived-backend-p backend 'html))
      output
    (let* ((layout (downcase (or (plist-get info :page-layout) "default")))
           (has-table (string-match-p "<table\\b" output))
           (body-classes
            (string-join
             (delq nil
                   (list "org-page"
                         (when has-table "has-table")
                         (when (string= layout "wide") "layout-wide")))
             " ")))
      ;; Add page classes to <body>.
      (setq output
            (replace-regexp-in-string
             "<body>"
             (format "<body class=\"%s\">" body-classes)
             output t t))

      ;; Wrap each exported table so very wide tables scroll independently.
      (setq output
            (replace-regexp-in-string
             "\\(<table\\b\\(?:.\\|\n\\)*?</table>\\)"
             "<div class=\"table-scroll\">\\1</div>"
             output t nil))
      output)))

(add-to-list 'org-export-filter-final-output-functions
             #'site-html-filter-final-output)

(setq org-html-validation-link nil
      org-html-head-include-default-style nil
      org-html-head-include-scripts nil
      org-html-html5-fancy t
      org-html-doctype "html5")

(defvar site-common-options
  `(:base-extension "org"
    :recursive t
    :publishing-function org-html-publish-to-html
    :with-toc t
    :section-numbers nil
    :html-head ,(site-html-head)
    :html-preamble site-html-preamble
    :html-postamble site-html-postamble
    :html-validation-link nil)
  "Options shared by protocol and snippet publishing projects.")

(setq org-publish-project-alist
      `(("protocols"
         :base-directory "org/protocols"
         :publishing-directory "public/protocols"
         ,@site-common-options
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Protocols")

        ("snippets"
         :base-directory "org/snippets"
         :publishing-directory "public/snippets"
         ,@site-common-options
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Code Snippets")

        ("home"
         :base-directory "org"
         :base-extension "org"
         :exclude ".*"
         :include ("index.org")
         :publishing-directory "public"
         :publishing-function org-html-publish-to-html
         :with-toc nil
         :section-numbers nil
         :html-head ,(site-html-head)
         :html-preamble site-html-preamble
         :html-postamble site-html-postamble
         :html-validation-link nil)

        ("static"
         :base-directory "org"
         :base-extension "css\\|png\\|jpg\\|jpeg\\|gif\\|svg\\|webp\\|pdf"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-publish-attachment)

        ("all" :components ("home" "protocols" "snippets" "static"))))

(org-publish-project "all" t)
