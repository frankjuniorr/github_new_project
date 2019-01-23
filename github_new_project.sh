#!/bin/bash

################################################################################
# Descrição:
#   Script usado para subir um código novo pro Github
#		Funcionalidades:
#			1. Cria um repositório novo
#			2. Manipula os labes na das issues
#				2.1 Cria um label novo chamado "TODO"
#				2.2 Altera a cor do label "bug"
#				2.3 Deleta o resto
#			3. Faz o deploy do código pro repostiório novo.
#
################################################################################
# Uso:
#    ./github_new_project.sh
#
################################################################################
# Dependencias:
# 1. jq [https://stedolan.github.io/jq/]
#				description: jq is a lightweight and flexible command-line JSON processor.
# 			instalação: 'sudo apt-get install jq'
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

	# load file with config parameters
	test -e "$(dirname $0)/config.sh" && . $_

	# github authorization request
	github_auth="Authorization: token $github_token"

  # mensagem de help
  nome_do_script=$(basename "$0")

  mensagem_help="
  Uso: $nome_do_script

Descrição:
 Script usado para subir um código novo pro Github
 Funcionalidades:
 1. Cria um repositório novo
 2. Manipula os labes na das issues
  2.1 Cria um label novo chamado "TODO"
  2.2 Altera a cor do label "bug"
  2.3 Deleta o resto
 3. Faz o deploy do código pro repostiório novo.

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

    printf "${amarelo}$1${reset}\n"
  }

  # ============================================
  # Função pra imprimir mensagem de sucesso
  # ============================================
  _print_success(){
    local verde="$(tput setaf 2 2>/dev/null || echo '\e[0;32m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${verde}$1${reset}\n"
  }

  # ============================================
  # Função pra imprimir erros
  # ============================================
  _print_error(){
    local vermelho="$(tput setaf 1 2>/dev/null || echo '\e[0;31m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${vermelho}[ERROR] $1${reset}\n"
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

  # ============================================
  # Verificar se um pacote está instalado
  # $1 --> nome do pacote que deseja verificar
  # $2 --> mensagem de erro customizada (OPCIONAL)
  # ============================================
  _die(){
    local package=$1
    local custom_msg=$2

    if ! type $package > /dev/null 2>&1; then
      _print_error "$package is not installed"
      test ! -z "$custom_msg" && _print_error "$custom_msg"
      exit $ERRO
    fi
  }

################################################################################
# Validações - regras de negocio até parametros

  # ============================================
  # tratamento de validacoes
  # ============================================
  validacoes(){
  	_die "jq"
    return "$SUCESSO"
  }

################################################################################
# Funções do Script - funções próprias e específicas do script

  # ============================================
  # Create new Github repository
  # ============================================
	create_new_repo(){
		local data_json='{"name": "@repo_name@"}'
		data_json=$(echo "$data_json" | sed "s/@repo_name@/${new_project_name}/")

		curl --request POST \
			--url https://api.github.com/user/repos \
			--header "$github_auth" \
			--data "$data_json"
	}

  # ============================================
  # Request to list all labes
  # ============================================
	list_all_labes(){
		local response_json=$(curl --silent --request GET \
	  --url https://api.github.com/repos/${github_user}/${new_project_name}/labels \
	  --header "$github_auth")


		labels_to_be_deleted=()
		local label=not_null
		local index=0
		while [ "$label" != "null" ]
		do
		  label=$(echo "$response_json" | jq --raw-output ".[$index].name")
		  # Only add in array the labels that differentto 'null', 'bug' and 'wontfix'
		  if [[ $label != "null" && $label != "bug" && $label != "wontfix" ]];then
		  	# add a temp hífen (-) to aux to separate array itens
		  	label=${label// /-}
		  	labels_to_be_deleted+=($label)
		  fi
		  index=$((index+1))
		done
	}

  # ============================================
  # Request to update label "Bug"
  # ============================================
	update_bug_label(){
		# color 'D32F2F' is Material Design Red 700
		local json_body='
	{
	  "name": "bug",
	  "description": "Bug fix required",
	  "color": "D32F2F"
	}'

		curl --request PATCH \
	  --url https://api.github.com/repos/${github_user}/${new_project_name}/labels/bug \
	  --header "$github_auth" \
	  --header 'Content-Type: application/json' \
	  --data "$json_body"
	}

  # ============================================
  # Request to create 'TODO' label
  # ============================================
	create_TODO_label(){
		# color '1976D2' is Material Design Blue 700
			local json_body='
	{
	  "name": "TODO",
	  "description": "new implementations",
	  "color": "1976D2"
	}'

		curl --request POST \
	  --url https://api.github.com/repos/${github_user}/${new_project_name}/labels \
	  --header "$github_auth" \
	  --header 'Content-Type: application/json' \
	  --data "$json_body"
	}

  # ============================================
  # Request to delete unused default labels
  # ============================================
	delete_unused_labels(){

		for item in "${labels_to_be_deleted[@]}"; do
				# replacing aux hífen (-) to '%20', 
				# that is character correspondent to 'space'
		   item=$(echo "$item" | sed 's/-/%20/g')

		   curl --request DELETE \
			  --url https://api.github.com/repos/${github_user}/${new_project_name}/labels/${item} \
			  --header "$github_auth" \
			  --header 'Content-Type: application/json'
		done
	}

  # ============================================
  # Deploy source codeto new repo
  # ============================================
	deploy_source_code(){
		git init
		git remote add origin git@github.com:${github_user}/${new_project_name}
		git config user.email "$github_user_email"
		git add .
		git commit -m "first commit"
		git push -u origin master
	}

  # ============================================
  # Função Main
  # ============================================
  main(){
		_print_info "Criando novo repositório"
  	create_new_repo

  	_print_info "Listando labels existentes"
    list_all_labes

    _print_info "Atualizando o label BUG"
		update_bug_label

		_print_info "Criando o label TODO"
		create_TODO_label

		_print_info "Deletando labels não usados"
		delete_unused_labels

		_print_info "Deploy código para o repositório"
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
