#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq nix-prefetch-git

set -e
#
# Resolve the real path to this script, following symlinks, so PACKAGE_FILE
# is always found relative to where the script itself lives, not $PWD.
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/default.nix"
REPO_URL="gitea@git.kopatz.dev:oberprofis/hub.git" # Replace with the repository URL

echo "Fetching latest revision from $REPO_URL..."

# Get the latest revision and sha256
latest_rev=$(nix-prefetch-git $REPO_URL | jq -r '.rev')

echo "Latest revision: $latest_rev"

# Update the package file with the new revision and sha256
sed -i "s|rev = \".*\";|rev = \"$latest_rev\";|" $PACKAGE_FILE

echo "Package file $PACKAGE_FILE updated successfully."

