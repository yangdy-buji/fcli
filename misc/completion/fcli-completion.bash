_fcli_runtime_types="python2.7 python3 nodejs6 java8"
_fcli_sub_command="config function help service shell version"
_fcli_config_args="--access-key-id --access-key-secret --api-version --debug --display --endpoint --help --security-token --timeout"

_fcli_function_create_args="-b --code-bucket -d --code-dir --code-file -o --code-object --description -f --function-name -h --handler --help -m --memory -t --runtime -s --service-name --timeout"

_fcli_function_update_args="-b --bucket --code-dir --code-file -d --description --etag -f --function-name -h --handler --help -m --memory -o --object -t --runtime -s --service-name --timeout"
_fcli_function_delete_args="--etag -f --function-name -s --service-name"
_fcli_function_list_args="--help -l --limit --name-only -t --next-token -p --prefix -s --service-name -k --start-key"
_fcli_function_get_args="-f --function-name --help -s --service-name"
_fcli_function_logs_args="--end -f --function-name -h --help -s --service-name --start"
_fcli_function_invoke_args="-d --debug --event-file --event-str -f --function-name --help --invocation-type -o --output -s --service-name"

_fcli_service_create_args="--description --help -p --log-project -l --log-store -r --role-arn -s --service-name"
_fcli_service_update_args="--description --etag --help -p --log-project -l --log-store -r --role -s --service-name"
_fcli_service_delete_args="--etag --help -s --service-name"
_fcli_service_list_args="--help -l --limit --name-only -t --next-token -p --prefix -k --start-key"
_fcli_service_get_args="--help -s --service-name"

function __fcli_dirs() {
	find . -type d -depth 1 | sed 's:^./::'
}

function __fcli_get_cur_code_dir() {
	local isFound="false"
	for word in ${COMP_WORDS[@]}; do
		if [ "$isFound" = true ]; then
			echo "$word"
			break
		fi
		if [ "$word" = "--code-dir" ]; then
			isFound=true
		fi
	done
}

function __fcli_remove_exist_args() {
	echo "$@ ${COMP_WORDS[@]} ${COMP_WORDS[@]}" | grep -o '[^ ]\+' | sort | uniq -u
}

function __fcli_handler_names() {
	# handle python
	for f in $(ls $(__fcli_get_cur_code_dir)/* | grep '\.py$'); do grep -H '^def\s\+\w\+(\w\+, \w\+):' $f | awk -F '[: (]' '{printf "%s.%s\n", $1, $3}' ; done | sed 's:\.py\.:.:;s:[^/]*/::'
}

function __fcli_get_all_service_name() {
	local len=${#COMP_WORDS[@]}
	local last_word="${COMP_WORDS[$COMP_CWORD]}"
	fcli service list | grep '^[ ]\+"[^:]*",*$' | grep -o '[a-zA-Z0-9_\-]\+'
	if [ x"$last_word" != x ]; then
		fcli service list --prefix $last_word | grep '^[ ]\+"[^:]*",*$' | grep -o '[a-zA-Z0-9_\-]\+'
	fi
}

function __fcli_get_cur_service_name() {
	local isFound="false"
	for word in "${COMP_WORDS[@]}"; do
		if [ "$isFound" = true ]; then
			echo "$word"
			break
		fi
		if [ "$word" = "--service-name" ] || [ "$word" = "-s" ]; then
			isFound=true
		fi
	done
}

function __fcli_get_all_function_name() {
	local service_name="$(__fcli_get_cur_service_name)"
	if [ "$service_name" != "" ]; then
		fcli function list --service-name "$service_name" | grep '^[ ]\+"[^:]*",*$' | grep -o '[a-zA-Z0-9_\-]\+'
	fi
}


function _fcli() {
	local cur prev opts

	COMPREPLY=()

	subcommand="${COMP_WORDS[1]}"
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	if [ $COMP_CWORD = 1 ] ; then
		opts="$(__fcli_remove_exist_args $_fcli_sub_command)"
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		return 0
	elif [ $COMP_CWORD -gt 1 ]; then
		case "$subcommand" in
			config)
				opts="$(__fcli_remove_exist_args $_fcli_config_args)"
				COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
				return 0
				;;
			function)
				if [ $COMP_CWORD = 2 ]; then
					opts="$(__fcli_remove_exist_args create update invoke get delete list logs)"
					COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
					return 0
				fi
				f_cmd=${COMP_WORDS[2]}
				case "$f_cmd" in 
					create)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--code-dir)
								opts="$(__fcli_dirs)"
								;;
							--handler|-h)
								opts="$(__fcli_handler_names)"
								;;
							--runtime|-t)
								opts="$_fcli_runtime_types"
								;;
							*)
								opts="$_fcli_function_create_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					update)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--function-name|-f)
								opts="$(__fcli_get_all_function_name)"
								;;
							--code-dir)
								opts="$(__fcli_dirs)"
								;;
							--handler|-h)
								opts="$(__fcli_handler_names)"
								;;
							--runtime|-t)
								opts="$_fcli_runtime_types"
								;;
							*)
								opts="$_fcli_function_update_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					list)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							*)
								opts="$_fcli_function_list_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					delete)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--function-name|-f)
								opts="$(__fcli_get_all_function_name)"
								;;
							*)
								opts="$_fcli_function_delete_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					get)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--function-name|-f)
								opts="$(__fcli_get_all_function_name)"
								;;
							*)
								opts="$_fcli_function_get_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					invoke)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--function-name|-f)
								opts="$(__fcli_get_all_function_name)"
								;;
							--event-file)
								opts="$(ls)"
								;;
							--invocation-type)
								opts="Sync Async"
								;;
							*)
								opts="$_fcli_function_invoke_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					logs)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							--function-name|-f)
								opts="$(__fcli_get_all_function_name)"
								;;
							*)
								opts="$_fcli_function_logs_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
				esac
				;;
			service)
				if [ $COMP_CWORD = 2 ]; then
					opts="$(__fcli_remove_exist_args create update get delete list)"
					COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
					return 0
				fi
				f_cmd=${COMP_WORDS[2]}
				case "$f_cmd" in 
					create)
						opts="$(__fcli_remove_exist_args ${_fcli_service_create_args})"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					update)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							*)
								opts="$_fcli_service_update_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					list)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							*)
								opts="$_fcli_service_list_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					delete)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							*)
								opts="$_fcli_service_delete_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
					get)
						local opts
						case $prev in 
							--service-name|-s)
								opts="$(__fcli_get_all_service_name)"
								;;
							*)
								opts="$_fcli_service_get_args"
								;;
						esac
						opts="$(__fcli_remove_exist_args $opts)"
						COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
						return 0
						;;
				esac
				;;
			help)
				opts="$(__fcli_remove_exist_args $_fcli_sub_command)"
				COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
				return 0
				;;
		esac
	fi
}

complete -F _fcli fcli
