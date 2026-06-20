(require 'ox-publish)

(setq org-publish-project-alist
      '(("protocols"
         :base-directory "org/protocols"
         :base-extension "org"
         :publishing-directory "public/protocols"
         :recursive t
         :publishing-function org-html-publish-to-html
         :with-toc t
         :section-numbers nil
         :html-head "<link rel=\"stylesheet\" href=\"../style.css\" type=\"text/css\"/>"
         :html-validation-link nil
         :html-postamble "<p>Last built: %T</p>"
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Protocols")

        ("snippets"
         :base-directory "org/snippets"
         :base-extension "org"
         :publishing-directory "public/snippets"
         :recursive t
         :publishing-function org-html-publish-to-html
         :with-toc t
         :section-numbers nil
         :html-head "<link rel=\"stylesheet\" href=\"../style.css\" type=\"text/css\"/>"
         :html-validation-link nil
         :html-postamble "<p>Last built: %T</p>"
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
         :html-head "<link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\"/>"
         :html-validation-link nil
         :html-postamble "<p>Last built: %T</p>")

        ("static"
         :base-directory "org"
         :base-extension "css\\|png\\|jpg\\|jpeg\\|gif\\|svg\\|webp\\|pdf"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-publish-attachment)

        ("all" :components ("home" "protocols" "snippets" "static"))))

(org-publish-project "all" t)
