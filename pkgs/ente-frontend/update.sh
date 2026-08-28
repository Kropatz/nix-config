#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq nix-prefetch-git

set -e

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$SCRIPT_DIR"

PACKAGE_FILE="default.nix" # Replace with your package file path
REPO_URL="gitea@git.kopatz.dev:oberprofis/ente.git" # Replace with the repository URL

echo "Fetching latest revision from $REPO_URL..."

# Get the latest revision and sha256
latest_rev=$(nix-prefetch-git $REPO_URL | jq -r '.rev')

echo "Latest revision: $latest_rev"

# Update the package file with the new revision and sha256
sed -i "s|rev = \".*\";|rev = \"$latest_rev\";|" $PACKAGE_FILE

echo "Package file $PACKAGE_FILE updated successfully."

