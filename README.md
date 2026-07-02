# dockerop

`dockerop` lance OpenCode dans un conteneur Docker isole pour le dossier courant.

Le but est d'avoir une instance OpenCode separee par projet, avec un `machine_id`
aleatoire et tout l'etat local dans `.dockerop/`.

## Utilisation rapide

```bash
./dockerop
./dockerop start
./dockerop init
./dockerop status
```

`./dockerop` sans sous-commande fait la meme chose que `./dockerop start`.
Si `start` est lance avant `init`, l'initialisation est faite automatiquement et
reste silencieuse.

Au lancement, `dockerop` affiche un petit banner avec le logo, la version, le
projet, le `machine_id`, le chemin monte dans Docker et le dossier d'etat. Pour
un usage script, utilise `dockerop start --no-banner`.

## Commandes

```bash
dockerop start              # lance OpenCode dans Docker
dockerop -s ses_xxxx        # lance OpenCode avec une session precise
dockerop start -s ses_xxxx  # equivalent explicite
dockerop start --no-banner  # lance sans presentation
dockerop init               # cree .dockerop/
dockerop init --method install-script # image locale avec install officiel
dockerop init --method npm  # image locale avec installation npm
dockerop init --method image # image officielle OpenCode, optionnel
dockerop use image          # repasse un projet existant en mode sans build
dockerop build              # construit l'image Docker
dockerop status             # affiche le projet, machine_id et state
dockerop config             # affiche la config Docker Compose resolue
dockerop doctor             # verifie Docker et la config
dockerop stop               # arrete les ressources Docker
dockerop reset --yes        # vide state/ en gardant config et machine_id
dockerop destroy --yes      # supprime .dockerop/
dockerop destroy --image -y # supprime aussi l'image locale generee
dockerop version            # affiche la version
dockerop help               # affiche l'aide
```

Alias utiles :

```bash
dockerop run
dockerop s
dockerop ps
dockerop rm
dockerop ?
dockerop --h
dockerop --version
```

Pour passer des arguments a OpenCode :

```bash
dockerop start -- --help
```

Pour reprendre/reinitialiser une session OpenCode precise :

```bash
dockerop -s ses_xxxx
dockerop start -s ses_xxxx
```

## Installation

Installation directe Linux/macOS depuis GitHub :

```bash
curl -fsSL https://raw.githubusercontent.com/previraza/dockerop/main/bootstrap.sh | sh
```

Installation Windows PowerShell :

```powershell
iwr https://raw.githubusercontent.com/previraza/dockerop/main/install.ps1 -UseB | iex
```

Installation avec npm depuis GitHub :

```bash
npm install -g github:previraza/dockerop
```

Installation avec pnpm depuis GitHub :

```bash
pnpm add -g github:previraza/dockerop
```

Installation avec `git clone` :

```bash
git clone https://github.com/previraza/dockerop.git ~/.local/share/dockerop
~/.local/share/dockerop/install.sh
```

Depuis ce dossier :

```bash
./dockerop install
```

Par defaut, la commande installe un lien symbolique dans `~/.local/bin/dockerop`.
Si `~/.local/bin` n'est pas dans le `PATH`, ajoute-le :

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Options :

```bash
./dockerop install --copy
./dockerop install --force
./dockerop install --target /usr/local/bin
```

Installateur shell equivalent :

```bash
./bootstrap.sh
./install.sh
DOCKEROP_FORCE_INSTALL=1 ./install.sh
DOCKEROP_INSTALL_MODE=copy ./install.sh
DOCKEROP_INSTALL_DIR=/usr/local/bin ./install.sh
```

Desinstallation :

```bash
./uninstall.sh
npm uninstall -g dockerop
pnpm remove -g dockerop
```

## Ce qui est cree

`init` cree un dossier `.dockerop/` dans le projet courant avec :

- `config.json` : identifiant du projet, nom d'image, nom du conteneur et `machine_id` aleatoire.
- `Dockerfile` : seulement en mode `install-script` ou `npm`.
- `compose.yaml` : service Docker Compose qui lance `opencode`.
- `.gitignore` : ignore l'etat local de runtime si `.dockerop/` est versionne volontairement.
- `state/` : home, config, cache, data npm et fichier `/etc/machine-id` dedies a cette instance.

Le projet courant est monte dans le conteneur sous `/workspace`. Le conteneur ne
monte pas le dossier parent du projet.

Le montage utilise le chemin absolu du dossier ou `dockerop` est lance. Donc si
tu lances `dockerop` dans un projet Next.js, `ls` dans OpenCode doit voir les
fichiers de ce projet, pas le dossier `.dockerop/`.

Ce n'est pas un clone Git : Docker monte le dossier courant en bind mount
lecture/ecriture. Les fichiers restent sur l'hote et OpenCode peut les lire,
modifier et creer directement depuis le conteneur.

A chaque `dockerop start`, `compose.yaml` est regenere avec le `pwd` courant.
Si tu deplaces un projet, `dockerop` met aussi `project_root` a jour.

## Git

`dockerop init` ajoute automatiquement `.dockerop/` au `.gitignore` du projet
courant. C'est le comportement recommande pour tes projets Next.js ou autres :
chaque projet garde son etat OpenCode local sans le publier.

Le fichier `.dockerop/.gitignore` est aussi genere. Il ignore `state/`, les logs
et fichiers temporaires au cas ou tu decides plus tard de versionner certains
fichiers de `.dockerop/` manuellement.

Ce dossier de developpement contient un repertoire `.git`, mais il n'est pas un
depot Git valide dans l'environnement actuel. Je n'execute pas `git init`
automatiquement pour eviter de modifier une structure Git existante.

## Fichiers du projet

```text
dockerop       CLI principal
bootstrap.sh   installateur direct depuis GitHub
install.sh     installateur shell
uninstall.sh   desinstallateur shell
install.ps1    installateur Windows PowerShell
package.json   installation npm/pnpm depuis GitHub
README.md      documentation
LICENSE        licence MIT
VERSION        version courante
CHANGELOG.md   historique des changements
Makefile       raccourcis install/uninstall/check
```

## Prerequis

- Docker avec `docker compose`.
- Python 3 sur la machine hote.
- Sur Windows : Docker Desktop, Python installe et disponible via `python`.

## Notes Docker

- Docker et le plugin `docker compose` doivent etre disponibles.
- Le mode par defaut est `image`, donc Docker tire `ghcr.io/anomalyco/opencode` sans build local.
- Le `machine_id` reste isole car `.dockerop/state/machine-id` est monte sur `/etc/machine-id:ro`.
- Si tu vois `RUN apt-get update`, le projet est encore en mode `install-script`; lance `dockerop use image`.
- `dockerop init --method install-script` construit une image locale et installe OpenCode avec `curl -fsSL https://opencode.ai/install | bash`.
- `dockerop init --method npm` reste disponible si tu veux comparer avec `npm install -g opencode-ai`.
- `.dockerop/` est ajoute au `.gitignore` pour eviter de versionner l'etat local.
