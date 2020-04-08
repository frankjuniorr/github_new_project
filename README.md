# Github New Project

[![environment](https://img.shields.io/badge/linux-ubuntu-orange.svg)](https://img.shields.io/badge/linux-ubuntu-orange.svg)

## Description
Script to create a new github repository from my [repository template](https://github.com/frankjuniorr/template-repository) and deploy source code.

## Features:
  - Create a new Github repository from template
  - Make deploy source code to new repository

 ## Config

Create a file call ```config.sh``` to save your data, with content:

```sh
# token created in github Settings > Developer Settings > Personal Access Token
github_token='<YOUR_TOKEN>'
github_user='<YOUR_GITHUB_USER>'
```

## Tip
To use better, is recommended add this script in your alias:

```sh
alias github_new_project="bash <YOUR_PATH>/github_new_project/github_new_project.sh"
```

So, with this, is just call alias inside to the new root folder that you wish create in github

----

  ### License:
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>


[Creative Commons 4.0](LICENSE) © <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Attribution-NonCommercial-ShareAlike 4.0 International</a>
