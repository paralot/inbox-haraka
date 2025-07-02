#!/bin/bash

# Exit on error
set -e

# Get latest tag (sorted by version, not by commit date)
latest_tag=$(git tag --sort=-i:refname | head -n 1)

if [ -z "$latest_tag" ]; then
  echo "❌ No tags found in this repository."
  exit 1
fi

# Strip "i" prefix and split into version parts
version=${latest_tag#i}
IFS='.' read -r major minor patch <<< "$version"

echo "🔖 Current version: $latest_tag"
echo "What do you want to bump?"
echo "1) Patch ($major.$minor.$((patch + 1)))"
echo "2) Minor ($major.$((minor + 1)).0)"
echo "3) Major ($((major + 1)).0.0)"

read -rp "Enter your choice [1-3, default=1]: " choice
choice=${choice:-1}

case "$choice" in
  1)
    patch=$((patch + 1))
    ;;
  2)
    minor=$((minor + 1))
    patch=0
    ;;
  3)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  *)
    echo "❌ Invalid choice. Aborting."
    exit 1
    ;;
esac

# Compose new tag
new_tag="i$major.$minor.$patch"

# Auto-generate message
tag_message="Release $new_tag"

# Create and push tag
git tag -a "$new_tag" -m "$tag_message"
git push origin "$new_tag"

echo "✅ Created and pushed tag: $new_tag"

