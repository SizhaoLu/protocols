(require 'ox-publish)

(setq org-publish-project-alist
      '(("protocols"
         :base-directory "org"
         :base-extension "org"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-html-publish-to-html
         :with-toc t
         :section-numbers nil
         :html-head "<link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\"/>"
         :html-validation-link nil
         :html-postamble "<p>Last built: %T</p>"
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Experimental Protocols")

        ("protocols-static"
         :base-directory "org"
         :base-extension "css\\|png\\|jpg\\|gif\\|pdf"
         :publishing-directory "public"
         :recursive t
         :publishing-function org-publish-attachment)

        ("all" :components ("protocols" "protocols-static"))))

(org-publish-project "all" t)
