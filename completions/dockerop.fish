complete -c dockerop -f

# Global flags
complete -c dockerop -l version -d 'show dockerop version'
complete -c dockerop -s s -l session -d 'start OpenCode with a session id'
complete -c dockerop -s us -l uppershell -d 'mount UpperShell socket into the container'
complete -c dockerop -s v -l volume -d 'extra volume mount host:container'
complete -c dockerop -l memory -d 'container memory limit'
complete -c dockerop -l cpus -d 'container CPU limit'
complete -c dockerop -l gpu -d 'enable NVIDIA GPU passthrough'

# Subcommands
complete -c dockerop -n __fish_use_subcommand -a init -d 'create .dockerop/ configuration'
complete -c dockerop -n __fish_use_subcommand -a start -d 'start OpenCode in Docker'
complete -c dockerop -n __fish_use_subcommand -a run -d 'run a command in the container'
complete -c dockerop -n __fish_use_subcommand -a shell -d 'open a shell in the container'
complete -c dockerop -n __fish_use_subcommand -a build -d 'build the OpenCode Docker image'
complete -c dockerop -n __fish_use_subcommand -a use -d 'switch OpenCode install method'
complete -c dockerop -n __fish_use_subcommand -a network -d 'switch Docker network mode'
complete -c dockerop -n __fish_use_subcommand -a sessions -d 'switch OpenCode session storage'
complete -c dockerop -n __fish_use_subcommand -a netcheck -d 'check DNS and HTTPS'
complete -c dockerop -n __fish_use_subcommand -a stop -d 'stop Docker resources'
complete -c dockerop -n __fish_use_subcommand -a destroy -d 'remove .dockerop/ and Docker resources'
complete -c dockerop -n __fish_use_subcommand -a reset -d 'reset state or machine id'
complete -c dockerop -n __fish_use_subcommand -a status -d 'show current dockerop config'
complete -c dockerop -n __fish_use_subcommand -a config -d 'print resolved Docker Compose config'
complete -c dockerop -n __fish_use_subcommand -a doctor -d 'check Docker and project configuration'
complete -c dockerop -n __fish_use_subcommand -a install -d 'install dockerop in PATH'
complete -c dockerop -n __fish_use_subcommand -a version -d 'show dockerop version'
complete -c dockerop -n __fish_use_subcommand -a update -d 'update dockerop to the latest version'
complete -c dockerop -n __fish_use_subcommand -a mi -d 'show or reset machine id'
complete -c dockerop -n __fish_use_subcommand -a help -d 'show help'

# init
complete -c dockerop -n '__fish_seen_subcommand_from init' -l force -d 'rewrite generated files'
complete -c dockerop -n '__fish_seen_subcommand_from init' -l method -d 'install method' -a 'image npm install-script'
complete -c dockerop -n '__fish_seen_subcommand_from init' -s q -l quiet -d 'only print errors'

# start/run
complete -c dockerop -n '__fish_seen_subcommand_from start run' -l no-build -d 'do not build the Docker image'
complete -c dockerop -n '__fish_seen_subcommand_from start run' -l no-banner -d 'do not print banner'

# shell
complete -c dockerop -n '__fish_seen_subcommand_from shell' -s us -l uppershell -d 'mount UpperShell socket'
complete -c dockerop -n '__fish_seen_subcommand_from shell' -s v -l volume -d 'extra volume mount'

# use
complete -c dockerop -n '__fish_seen_subcommand_from use' -a 'image npm install-script'

# network
complete -c dockerop -n '__fish_seen_subcommand_from network' -a 'bridge host auto'

# sessions
complete -c dockerop -n '__fish_seen_subcommand_from sessions' -a 'isolated host'

# destroy
complete -c dockerop -n '__fish_seen_subcommand_from destroy' -l yes -d 'skip confirmation'
complete -c dockerop -n '__fish_seen_subcommand_from destroy' -l image -d 'also remove local image'

# reset
complete -c dockerop -n '__fish_seen_subcommand_from reset' -a 'state machineId'
complete -c dockerop -n '__fish_seen_subcommand_from reset' -l yes -d 'skip confirmation'

# status
complete -c dockerop -n '__fish_seen_subcommand_from status' -l json -d 'print raw JSON config'

# mi
complete -c dockerop -n '__fish_seen_subcommand_from mi' -a reset

# logs
complete -c dockerop -n '__fish_seen_subcommand_from logs' -s n -l tail -d 'number of lines'
complete -c dockerop -n '__fish_seen_subcommand_from logs' -s f -l follow -d 'follow output'

# update
complete -c dockerop -n '__fish_seen_subcommand_from update' -l force -d 'force update'
