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
   ;; Apply a saved theme before the page paints to avoid a flash of the
   ;; wrong theme. If no preference is saved, CSS follows the OS setting.
   "<script>(function(){try{var t=localStorage.getItem('protocols-theme');if(t==='light'||t==='dark'){document.documentElement.dataset.theme=t;}}catch(e){}})();</script>\n"
   "<link rel=\"stylesheet\" href=\"" site-root "/style.css\" type=\"text/css\" />"))

(defun site-html-preamble (_info)
  "Shared site header."
  (format
   (concat
    "<header class=\"site-header\">"
    "<div class=\"site-header-inner\">"
    "<a class=\"site-title\" href=\"%s/\">Protocols</a>"
    "<div class=\"site-actions\">"
    "<nav class=\"site-nav\" aria-label=\"Primary\">"
    "<a href=\"%s/protocols/\">Protocols</a>"
    "<a href=\"%s/snippets/\">Snippets</a>"
    "</nav>"
    "<button class=\"theme-toggle\" type=\"button\" aria-label=\"Toggle light and dark theme\" title=\"Toggle light and dark theme\">"
    "<span class=\"theme-toggle-icon\" aria-hidden=\"true\">◐</span>"
    "<span class=\"theme-toggle-label\">Theme</span>"
    "</button>"
    "</div>"
    "</div>"
    "</header>"
    "<script>"
    "(function(){"
    "var b=document.querySelector('.theme-toggle');if(!b)return;"
    "function effective(){var t=document.documentElement.dataset.theme;if(t)return t;return window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';}"
    "function sync(){var t=effective();b.setAttribute('aria-pressed',t==='dark'?'true':'false');b.querySelector('.theme-toggle-label').textContent=t==='dark'?'Light':'Dark';}"
    "b.addEventListener('click',function(){var next=effective()==='dark'?'light':'dark';document.documentElement.dataset.theme=next;try{localStorage.setItem('protocols-theme',next);}catch(e){}sync();});"
    "var mq=window.matchMedia('(prefers-color-scheme: dark)');if(mq.addEventListener){mq.addEventListener('change',function(){if(!document.documentElement.dataset.theme)sync();});}"
    "sync();"
    "})();"
    "</script>")
   site-root site-root site-root))

(defun site-html-postamble (_info)
  "Shared footer with an explicit build timestamp."
  (format
   "<footer class=\"site-footer\"><p>Last built: %s</p></footer>"
   (format-time-string "%Y-%m-%d %H:%M %Z")))


(defun site-page-layout-from-source (info)
  "Return PAGE_LAYOUT from the current Org source file, if present."
  (let ((input-file (plist-get info :input-file)))
    (when (and input-file (file-readable-p input-file))
      (with-temp-buffer
        (insert-file-contents input-file)
        (goto-char (point-min))
        (let ((case-fold-search t))
          (when (re-search-forward
                 "^[ \t]*#\\+PAGE_LAYOUT:[ \t]*\\([^\n\r]+\\)" nil t)
            (string-trim (match-string 1))))))))

(defun site-html-filter-final-output (output backend info)
  "Apply site-specific HTML enhancements to OUTPUT.

Tables are wrapped in a horizontally scrollable container. Pages that
contain a table get a wider content class automatically. PAGE_LAYOUT=wide
adds an explicit extra-wide layout class."
  (if (not (org-export-derived-backend-p backend 'html))
      output
    (let* ((layout (downcase
                    (or (site-page-layout-from-source info)
                        (plist-get info :page-layout)
                        "default")))
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
