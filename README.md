# Github New Project

[![environment](https://img.shields.io/badge/linux-ubuntu-orange.svg)](https://img.shields.io/badge/linux-ubuntu-orange.svg)

## Description
Script to create a new github repository and deploy source code.

## Features:
  - Create a new Github repository
  - Create a new issue label "TODO"
  - Change color to the label "bug"
  - Make deploy source code to new repository

## Dependencies

  - [jq](https://stedolan.github.io/jq/) - jq is a lightweight and flexible command-line JSON processor.
  
 ## Config

Create a file call ```config.sh``` to save your data, with content:

```sh
# token created in github Settings > Developer Settings > Personal Access Token
github_token='<YOUR_TOKEN>'
github_user='<YOUR_GITHUB_USER>'
github_user_email='<YOUR_EMAIL>'
```

## Tip
To use better, is recommended add this script in your alias:

```sh
alias github_new_project="bash <YOUR_PATH>/github_new_project/github_new_project.sh"
```

So, with this, is just call alias inside to the new root folder that you wish create in github
