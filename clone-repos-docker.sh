#!/bin/bash
#
# clone-repos.sh
# Clone une liste de dépôts Git dans le dossier parent (~/docker)
#
# Usage : ./clone-repos.sh
# Placer ce script dans ~/docker/scripts/ par exemple, il clonera dans ~/docker/

set -euo pipefail

# ---------------------------------------------------------
# Liste des dépôts à cloner (ajoute/retire une ligne ici)
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

echo "Destination des clones : $DEST_DIR"
echo ""

for repo in "${REPOS[@]}"; do
    # Extrait le nom du dossier à partir de l'URL (enlève .git à la fin)
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

echo "Terminé."
