#!/usr/bin/env bash
_dockerop_completions() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="init start run shell build use network sessions netcheck stop down destroy rm reset status ps config doctor install version update mi help"

    if [[ ${cur} == -* ]]; then
        local flags="--version --session --uppershell --volume --memory --cpus --gpu --help"
        COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
        return 0
    fi

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        init)
            COMPREPLY=( $(compgen -W "--force --method --quiet image npm install-script" -- ${cur}) )
            ;;
        start|run|s)
            COMPREPLY=( $(compgen -W "--no-build --no-banner --session --uppershell --volume --memory --cpus --gpu" -- ${cur}) )
            ;;
        shell|sh)
            COMPREPLY=( $(compgen -W "--uppershell --volume" -- ${cur}) )
            ;;
        use)
            COMPREPLY=( $(compgen -W "image npm install-script" -- ${cur}) )
            ;;
        network)
            COMPREPLY=( $(compgen -W "bridge host auto" -- ${cur}) )
            ;;
        sessions)
            COMPREPLY=( $(compgen -W "isolated host" -- ${cur}) )
            ;;
        destroy|rm)
            COMPREPLY=( $(compgen -W "--yes --image" -- ${cur}) )
            ;;
        reset)
            COMPREPLY=( $(compgen -W "state machineId --yes" -- ${cur}) )
            ;;
        status|ps)
            COMPREPLY=( $(compgen -W "--json" -- ${cur}) )
            ;;
        mi)
            COMPREPLY=( $(compgen -W "reset" -- ${cur}) )
            ;;
        logs)
            COMPREPLY=( $(compgen -W "--tail --follow" -- ${cur}) )
            ;;
        update)
            COMPREPLY=( $(compgen -W "--force" -- ${cur}) )
            ;;
        version|v)
            ;;
        help)
            ;;
    esac
    return 0
}
complete -F _dockerop_completions dockerop
