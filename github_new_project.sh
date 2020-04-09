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
    # load file with config parameters
    if [ -e "$(dirname $0)/config.sh" ];then
      source "$(dirname $0)/config.sh"
    else
      echo "create a config file (config.sh) fisrt"
      echo "read the README"
      exit "$ERRO"
    fi
  }

################################################################################
# Funções do Script - funções próprias e específicas do script

  # ============================================
  # Create new Github repository
  # ============================================
	create_new_repo(){
    # github authorization request
  	local github_auth="Authorization: token $github_token"

		local data_json='{"owner": "@repo_user@", "name": "@repo_name@", "private": false}'
    data_json=$(echo "$data_json" | sed "s/@repo_user@/${github_user}/")
		data_json=$(echo "$data_json" | sed "s/@repo_name@/${new_project_name}/")

    local endpoint="https://api.github.com/repos/${github_user}/template-repository/generate"

		curl --request POST \
			--url "$endpoint" \
			--header "$github_auth" \
      --header "Accept: application/vnd.github.baptiste-preview+json" \
			--data "$data_json"
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
