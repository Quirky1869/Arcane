#!/bin/bash
#
# clone-repos.sh
# 1. Clone une liste de dépôts Git externes dans le dossier parent (~/docker)
# 2. Copie les projets locaux (~/docker/Arcane/projects/*) vers ~/docker
#    pour qu'Arcane puisse les détecter
#
# Usage : ./clone-repos.sh
# Placer ce script dans ~/docker/scripts/ (ou ~/docker/Arcane/), il travaille
# toujours par rapport à ~/docker en tant que dossier parent.

set -euo pipefail

# ---------------------------------------------------------
# Liste des dépôts externes à cloner (ajoute/retire une ligne ici)
# ---------------------------------------------------------
REPOS=(
    "git@github.com:Quirky1869/Purple-Spells.git"
    "https://github.com/Quirky1869/backup-calculator.git"
)

# ---------------------------------------------------------
# Dossier de destination : le parent du dossier du script
# ---------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$DEST_DIR/Arcane/projects"

echo "Destination : $DEST_DIR"
echo ""

# ---------------------------------------------------------
# 1. Clone des repos externes
# ---------------------------------------------------------
echo "=== Clonage des dépôts externes ==="
for repo in "${REPOS[@]}"; do
    repo_name="$(basename "$repo" .git)"
    target_path="$DEST_DIR/$repo_name"

    if [ -d "$target_path" ]; then
        echo "⏭  $repo_name existe déjà, on saute (utilise 'git -C $target_path pull' pour mettre à jour)."
        continue
    fi

    echo "⬇  Clonage de $repo_name..."
    if git clone "$repo" "$target_path"; then
        echo "✅ $repo_name cloné avec succès."
    else
        echo "❌ Échec du clonage de $repo_name."
    fi
    echo ""
done

# ---------------------------------------------------------
# 2. Synchronisation des projets locaux (it-tools, etc.)
# ---------------------------------------------------------
echo "=== Synchronisation des projets locaux (Arcane/projects) ==="

if [ -d "$PROJECTS_DIR" ]; then
    shopt -s nullglob
    local_projects=("$PROJECTS_DIR"/*/)

    if [ ${#local_projects[@]} -eq 0 ]; then
        echo "Aucun projet local trouvé dans $PROJECTS_DIR."
    else
        for dir in "${local_projects[@]}"; do
            name="$(basename "$dir")"
            target="$DEST_DIR/$name"

            echo "Synchronisation de $name..."

            if command -v rsync >/dev/null 2>&1; then
                rsync -a --delete "$dir" "$target/"
            else
                rm -rf "$target"
                cp -r "$dir" "$target"
            fi

            echo "✅ $name synchronisé vers $target"
        done
    fi
else
    echo "Aucun dossier $PROJECTS_DIR trouvé, étape ignorée."
fi

echo ""
echo "Terminé. Rafraîchis la page Projects dans Arcane si besoin."
