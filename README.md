# DiaTeX - Diagram and LaTeX support 

Add LaTeX and diagram support to notes stored on Github.
Just like using code blocks in Github Flavoured Markdown, you would do the same except replacing the language type
with `latex` or `diagram`. You can then run this on a pre-commit hook, or after commit using a continuous integration
solution.

LaTeX Cheatsheets can be found [here](https://wch.github.io/latexsheet/)
Diagram syntax can be found [here](https://knsv.github.io/mermaid/)

Usage
---

- `bundle install`
- `npm install mermaid --global`
- `bundle exec ./diatex <path_to_folder>`

OR

Install all gems system wide, then `./diatex <path_to_folder>`

Installation
---

1. Run `bin/setup` (on a Mac), otherwise make sure LaTeX and dvipng are installed.
2. Add 'GITHUB_ACCESS_TOKEN', 'GITHUB_PAGES_URL', 'GITHUB_REPO', 'GITHUB_BRANCH' variables
   These variables are used to upload images via the API to a Github Repo with Github pages enabled.
   This is where we host the images created during the conversion of a markdown file

Example
---
[This Gist](https://gist.github.com/jules2689/a6c812caac02c5c2956a70ef7e2a29c8) contains a `before.txt`, an `after.txt`, and a `as_markdown.md` file that is rendered from running DiaTeX on it.
