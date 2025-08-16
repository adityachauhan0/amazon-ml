#!/usr/bin/env bash
set -euo pipefail

MAIN_BRANCH="main"
PAGES_BRANCH="gh-pages"
VENV_DIR=".venv"

# activate env
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

# install deps if missing
pip install --quiet --upgrade pip
pip install --quiet mkdocs-material pymdown-extensions mkdocs-git-revision-date-localized-plugin

# commit + push main
git add -A
if ! git diff --cached --quiet; then
  git commit -m "update: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
fi
git push origin "$MAIN_BRANCH"

# deploy to gh-pages
mkdocs gh-deploy --remote-branch "$PAGES_BRANCH" --force

echo "✅ deployed to: https://adityachauhan0.github.io/amazon-ml/"
