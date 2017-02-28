# DiaTeX - Diagram and LaTeX support 

Add LaTeX and diagram support to notes stored on Github.
Just like using code blocks in Github Flavoured Markdown, you would do the same except replacing the language type
with `latex` or `diagram`. You can then run this on a pre-commit hook, or after commit using a continuous integration
solution.

LaTeX Cheatsheets can be found [here](https://wch.github.io/latexsheet/)
Diagram syntax: It is a limited diagram and currently only supports `>>` and `<<` for full, non-dotted lines. Source is available [here](https://github.com/hanachin/yuimaru)

Usage
---

`bundle install`
`bundle exec diatex <path_to_folder>`

OR

Install all gems system wide, then `diatex <path_to_folder>`

Installation
---

1. Run `bin/setup` (on a Mac), otherwise make sure LaTeX and dvipng are installed.
2. Add 'GITHUB_ACCESS_TOKEN', 'GITHUB_PAGES_URL', 'GITHUB_REPO', 'GITHUB_BRANCH' variables
   These variables are used to upload images via the API to a Github Repo with Github pages enabled.
   This is where we host the images created during the conversion of a markdown file

Example
---

This markdown file:
![Markdown File](https://cloud.githubusercontent.com/assets/3074765/23391674/99cb994a-fd44-11e6-863e-7534cc8eeee4.png)

Would be converted over to:
![Converted Markdown File](https://cloud.githubusercontent.com/assets/3074765/23391666/7f158bce-fd44-11e6-957c-9f4d9c0c393c.png)

Which would render as:
![Rendered File](https://cloud.githubusercontent.com/assets/3074765/23391659/7018e72e-fd44-11e6-9ccd-82c8e9da1d47.png)
