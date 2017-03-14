# DiaTeX - Diagram and LaTeX support 

Add LaTeX and diagram support to notes stored on Github.
Just like using code blocks in Github Flavoured Markdown, you would do the same except replacing the language type
with `latex` or `diagram`. You can then run this on a pre-commit hook, or after commit using a continuous integration
solution.

This hits a service I run on my [personal website](https://github.com/jules2689/website/blob/master/app/controllers/diatex_controller.rb).

- LaTeX Cheatsheets can be found [here](https://wch.github.io/latexsheet/)
- Diagram syntax can be found [here](https://knsv.github.io/mermaid/)
- This [Diagram Live Editor](https://knsv.github.io/mermaid/live_editor/) can be used to help you build a diagram

Usage
---

- Add the environment variable (`DIATEX_PASSWORD`) for the DIATEX service
- Add a [write-able deploy key for Circle](https://circleci.com/docs/1.0/adding-read-write-deployment-key/)
- Add a `circle.yml` file to your repo with these contents:
```yaml
checkout:
  post:
    - git submodule sync
    - git submodule update --init --recursive --remote # use submodules

test:
  override:
    - ruby ./diatex/diatex ./
    - git config --global user.email "julian+bot@jnadeau.ca" && git config --global user.name "Julian Bot"
    - git status
    - git add --all .
    - git commit -m 'Convert latex and diagram to images [ci skip]' || true
    - git push origin master || true
```
- Add a submodule to your repo `git submodule add https://github.com/jules2689/diatex`

Done!

Example
---
[This Gist](https://gist.github.com/jules2689/a6c812caac02c5c2956a70ef7e2a29c8) contains a `before.txt`, an `after.txt`, and a `as_markdown.md` file that is rendered from running DiaTeX on it.
