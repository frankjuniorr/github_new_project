# Github New Project

<p align="left">
  <a href="https://img.shields.io/badge/ubuntu-20.04-4A0048.svg">
    <img src="https://img.shields.io/badge/-ubuntu_20.04-4A0048.svg?style=for-the-badge&logo=ubuntu&logoColor=white">
  </a>
  <a href="https://img.shields.io/badge/terraform-623CE4.svg">
    <img src="https://img.shields.io/badge/-terraform-623CE4.svg?style=for-the-badge&logo=terraform&logoColor=white">
  </a>
  <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
    <img src="https://img.shields.io/badge/-CC_BY--SA_4.0-000000.svg?style=for-the-badge&logo=creative-commons&logoColor=white"/>
  </a>
</p>

## Description
Script to create a new github repository from my [repository template](https://github.com/frankjuniorr/template-repository) and deploy source code.

## Features:
  - Create a new Github repository from template
  - Make deploy source code to new repository

 ## Config

Create some environment vars first:

```bash
# token created in github Settings > Developer Settings > Personal Access Token
export TF_VAR_github_token=<GITHUB_TOKEN_HERE>
export TF_VAR_github_owner=<YOUR_GITHUB_USER_HERE>
```

## Tip
To use better, is recommended add this script in your alias:

```sh
alias github_new_project="bash <YOUR_PATH>/github_new_project/github_new_project.sh"
```

So, with this, is just call alias inside to the new root folder that you wish create in github

----

  ### License:

<p align="center">
  <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
    <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" />
  </a>
</p>
