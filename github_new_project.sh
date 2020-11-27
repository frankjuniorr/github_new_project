#!/bin/bash

################################################################################
# Descrição:
#   Script usado para subir um código novo pro Github
#		Funcionalidades:
#			1. Cria um repositório novo
#			3. Faz o deploy do código pro repostiório novo.
#
################################################################################
# Uso:
#    ./github_new_project.sh
#
################################################################################
# Autor: Frank Junior <frankcbjunior@gmail.com>
# Desde: 23-01-2019
# Versão: 1
################################################################################


################################################################################
# Configurações
# set:
# -e: se encontrar algum erro, termina a execução imediatamente
  set -e


################################################################################
# Variáveis - todas as variáveis ficam aqui

	# new project name is the current directory
	new_project_name=$(basename $(pwd))

  # mensagem de help
  nome_do_script=$(basename "$0")

  mensagem_help="
  Uso: $nome_do_script

Descrição:
 Script usado para subir um código novo pro Github
 Funcionalidades:
 1. Cria um repositório novo a partir do template
 2. Faz o deploy do código pro repostiório novo.

  Ex.: ./$nome_do_script
  "


################################################################################
# Utils - funções de utilidades

  # códigos de retorno
  # [condig-style] constantes devem começar com 'readonly'
  readonly SUCESSO=0
  readonly ERRO=1

  # debug = 0, desligado
  # debug = 1, ligado
  debug=0

  # ============================================
  # Função pra imprimir informação
  # ============================================
  _print_info(){
    local amarelo="$(tput setaf 3 2>/dev/null || echo '\e[0;33m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${amarelo}[LOG]: $1${reset}\n"
  }

  # ============================================
  # Função de debug
  # ============================================
  _debug_log(){
    if [ "$debug" = 1 ];then
       _print_info "[DEBUG] $*"
    fi
}

  # ============================================
  # tratamento das exceções de interrupções
  # ============================================
  _exception(){
    return "$ERRO"
  }

################################################################################
# Validações - regras de negocio até parametros

  # ============================================
  # tratamento de validacoes
  # ============================================
  validacoes(){
    # se não existir uma das duas, já exiba a mensagem de erro
    if [ -z $TF_VAR_github_owner ] || [ -z $TF_VAR_github_token ];then
      echo "Fisrt, set the necessary env vars:"
      echo 'export TF_VAR_github_token=<GITHUB_TOKEN_HERE>'
      echo 'export TF_VAR_github_owner=<YOUR_GITHUB_USER_HERE>'
      exit 1
    fi

    # se as 2 variáveis existem, aí sim, sete as variáveis necessárias
    if [ -n $TF_VAR_github_owner ] && [ -n $TF_VAR_github_token ];then
      github_user=$(env | grep "TF_VAR_github_owner" | cut -d "=" -f2)
    fi

    # installing Terraform depenency
    if ! type terraform > /dev/null 2>&1; then
      echo "terraform não está instalado. Instalando pra você..."
      terraform_zip_file="terraform_0.13.5_linux_amd64.zip"
      wget -P "https://releases.hashicorp.com/terraform/0.13.5/${terraform_zip_file}" "${HOME}/bin"
      unzip "${HOME}/bin/${terraform_zip_file}" -d "${HOME}/bin"
      rm -rf "${HOME}/bin/${terraform_zip_file}"
    fi
  }

################################################################################
# Funções do Script - funções próprias e específicas do script

  # ============================================
  # Create new Github repository
  # ============================================
	create_new_repo(){
    cd "$(dirname $0)/infra"
    terraform apply -auto-approve -var "project_name=${new_project_name}"
    output=$(terraform output)

    # setando as variáveis que vem do output
    github_user_email=$(echo "$output" | grep "github_user_email_output" | cut -d "=" -f2 | xargs)
    github_user_name=$(echo "$output" | grep "github_user_name_output" | cut -d "=" -f2 | xargs)

    echo "DEBUG:"
    echo "$github_user_email"
    echo "$github_user_name"

    cd - > /dev/null
	}

  # ============================================
  # Deploy source codeto new repo
  # ============================================
	deploy_source_code(){
    local temporary_folder="/tmp/temp_repo"
    _print_info "Clonando template"
		git clone git@github.com:${github_user}/${new_project_name} "$temporary_folder"

    _print_info "Copiando arquivos"
    cp -r ${temporary_folder}/* .

    _print_info "Copiando arquivos ocultos"
    cp -r ${temporary_folder}/.[^.]* .
    rm -rf "$temporary_folder"

    _print_info "Subindo o código"
    git config user.email "$github_user_email";
    git config user.name "$github_user_name";
		git add .
		git commit -m "upload code"
		git push -u origin master
	}

  # ============================================
  # Função Main
  # ============================================
  main(){
		_print_info "Criando novo repositório"
  	create_new_repo
		deploy_source_code
  }

  # ============================================
  # Função que exibe o help
  # ============================================
  verifyHelp(){
    case "$1" in

      # mensagem de help
      -h | --help)
        _print_info "$mensagem_help"
        exit "$SUCESSO"
      ;;

    esac
  }

################################################################################
# Main - execução do script

  # trata interrrupção do script em casos de ctrl + c (SIGINT) e kill (SIGTERM)
  trap _exception SIGINT SIGTERM
  verifyHelp "$1"
  validacoes
  main "$1"

################################################################################
# FIM do Script =D
