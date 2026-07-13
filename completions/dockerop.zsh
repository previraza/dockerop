#compdef dockerop

_dockerop() {
    local -a commands
    commands=(
        'init:create .dockerop/ configuration'
        'start:start OpenCode in Docker'
        'run:run a command in the container'
        'shell:open a shell in the dockerop container'
        'build:build the OpenCode Docker image'
        'use:switch OpenCode install method'
        'network:switch Docker network mode'
        'sessions:switch OpenCode session storage'
        'netcheck:check DNS and HTTPS from the container'
        'stop:stop Docker resources'
        'destroy:remove .dockerop/ and Docker resources'
        'reset:reset state or machine id'
        'status:show current dockerop config'
        'config:print resolved Docker Compose config'
        'doctor:check Docker and project configuration'
        'install:install dockerop in PATH'
        'version:show dockerop version'
        'update:update dockerop to the latest version'
        'mi:show or reset machine id'
        'help:show help'
    )

    _arguments -C \
        '--version[show dockerop version]' \
        '--session[session id]:session id:' \
        '--uppershell[mount UpperShell socket]' \
        '-v+[extra volume mount host:container]:volume:' \
        '--memory[memory limit]:memory:' \
        '--cpus[CPU limit]:cpus:' \
        '--gpu[enable NVIDIA GPU passthrough]' \
        '1:command:->cmd' \
        '*::arg:->args'

    case $state in
        cmd)
            _describe 'command' commands
            ;;
        args)
            case $words[1] in
                init)
                    _arguments \
                        '--force[rewrite generated files]' \
                        '--method[install method]:method:(image npm install-script)' \
                        '--quiet[only print errors]'
                    ;;
                start|run)
                    _arguments \
                        '--no-build[do not build the Docker image]' \
                        '--no-banner[do not print dockerop launch banner]' \
                        '--session[session id]:session id:' \
                        '--uppershell[mount UpperShell socket]' \
                        '-v+[extra volume mount]:volume:' \
                        '--memory[memory limit]:memory:' \
                        '--cpus[CPU limit]:cpus:' \
                        '--gpu[enable GPU passthrough]'
                    ;;
                shell)
                    _arguments \
                        '--uppershell[mount UpperShell socket]' \
                        '-v+[extra volume mount]:volume:'
                    ;;
                use)
                    _arguments '1:method:(image npm install-script)'
                    ;;
                network)
                    _arguments '1:mode:(bridge host auto)'
                    ;;
                sessions)
                    _arguments '1:mode:(isolated host)'
                    ;;
                destroy|rm)
                    _arguments '--yes[skip confirmation]' '--image[also remove local image]'
                    ;;
                reset)
                    _arguments '1:target:(state machineId)' '--yes[skip confirmation]'
                    ;;
                status|ps)
                    _arguments '--json[print raw JSON config]'
                    ;;
                mi)
                    _arguments '1:action:(reset)'
                    ;;
                logs)
                    _arguments '--tail[number of lines]:lines:' '--follow[follow output]'
                    ;;
                update)
                    '--force[force update]'
                    ;;
            esac
            ;;
    esac
}

_dockerop "$@"
