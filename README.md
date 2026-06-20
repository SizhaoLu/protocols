# wetlab-protocols

A collection of wet lab protocols and SOPs in Org mode and published with GitHub Pages.

🔗 **Live site:** [sizhaolu.github.io/protocols](https://sizhaolu.github.io/protocols/)

## About

This repo contains molecular biology and biochemistry protocols and
other SOPs I use in the lab, written in plain-text [Org mode](https://orgmode.org/) and automatically built into a static website.

## License

These protocols are licensed under [CC BY 4.0](LICENSE) — you're free to use, adapt, and redistribute them (even commercially), as long as you give appropriate credit.

## How this site is built

- Protocols are written as `.org` files under `org/`.
- [`publish.el`](publish.el) defines an Org publishing project (`org-publish-project-alist`) that exports each `.org` file to HTML, plus an auto-generated sitemap as the homepage.
- A [GitHub Actions workflow](.github/workflows/publish.yml) runs on every push to `main`:
  1. Checks out the repo
  2. Installs Emacs
  3. Runs `emacs --batch --load publish.el` to build the site into `public/`
  4. Deploys `public/` to the `gh-pages` branch via [`github-pages-deploy-action`](https://github.com/JamesIves/github-pages-deploy-action)
- GitHub Pages serves the site from the `gh-pages` branch (root).
