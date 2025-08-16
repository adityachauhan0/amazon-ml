#!/usr/bin/env bash
set -euo pipefail

# --- settings ---
GITHUB_USER="adityachauhan0"
REPO_NAME="amazon-ml"
VENV_DIR=".venv"
PY="${PY:-python3}"   # override with: PY=python bash deploy.sh
MAIN_BRANCH="main"
GH_PAGES_BRANCH="gh-pages"
# ---------------

# 1) Python env + deps
if [ ! -d "$VENV_DIR" ]; then
  "$PY" -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"
pip install --upgrade pip >/dev/null

if [ -f requirements.txt ]; then
  pip install -r requirements.txt >/dev/null
else
  pip install mkdocs-material pymdown-extensions mkdocs-git-revision-date-localized-plugin >/dev/null
fi

# sanity checks
[ -f mkdocs.yml ] || { echo "mkdocs.yml not found in $(pwd)."; exit 1; }
[ -d docs ] || { echo "docs/ directory not found."; exit 1; }

# 2) Commit & push to main (if repo is linked)
if [ -d .git ]; then
  # ensure on main
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
    git checkout -B "$MAIN_BRANCH"
  fi

  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "deploy: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  fi

  if git remote get-url origin >/dev/null 2>&1; then
    git push -u origin "$MAIN_BRANCH"
  else
    echo "NOTE: no 'origin' remote set. (See linking commands below.)"
  fi
else
  echo "NOTE: this folder isn't a git repo yet. (See linking commands below.)"
fi

# 3) Publish to gh-pages
"$VENV_DIR/bin/mkdocs" gh-deploy --branch "$GH_PAGES_BRANCH" --force

echo
echo "✅ Deployed. Site should be at: https://${GITHUB_USER}.github.io/${REPO_NAME}/"
