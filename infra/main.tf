#################################
#  Variáveis
#################################
variable "github_token" {
  description = "The github token"
  type        = string
}
variable "github_owner" {
  description = "The Github owner"
  type        = string
}
variable "project_name" {
  description = "The name of new repository"
  type        = string
}

#################################
#  Data to output
#################################
data "github_user" "user" {
  username = var.github_owner
}

#################################
#  Provider: Github
#################################
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

#################################
#  Recursos
#################################
resource "github_repository" "project" {
  name        = var.project_name
  description = "Projeto criado pelo github_new_project"

  visibility = "private"

  template {
    owner = var.github_owner
    repository = "template-repository"
  }
}

#################################
#  Outputs
#################################
output "github_user_name_output" {
  value = data.github_user.user.name
}
output "github_user_email_output" {
  value = data.github_user.user.email
}