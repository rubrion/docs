#!/usr/bin/env bash
# Fetches OVERVIEW.md + public-docs/*.md from each repo in repos.conf,
# assembles them into src/, and generates SUMMARY.md.
#
# repos.conf format: slug|github_repo|section_title[|subdir]
#   subdir  optional path prefix inside the repo (e.g. "rubot" for a sub-project
#           whose files live at rubot/OVERVIEW.md and rubot/public-docs/)
#
# Usage:
#   DOCS_PAT=ghp_xxx bash scripts/assemble-docs.sh   # CI (private repos)
#   bash scripts/assemble-docs.sh                      # local (public or SSH)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/repos.conf"
SRC="$ROOT/src"
TMP="$ROOT/_repos"

if [[ -n "${DOCS_PAT:-}" ]]; then
  GIT_REMOTE="https://x-access-token:${DOCS_PAT}@github.com/"
else
  GIT_REMOTE="https://github.com/"
fi

rm -rf "$TMP"
mkdir -p "$TMP"

# ── Fetch repos and copy docs ────────────────────────────────────
while IFS='|' read -r slug repo title subdir; do
  [[ "$slug" =~ ^[[:space:]]*# || -z "$slug" ]] && continue
  slug="$(echo "$slug" | xargs)"
  repo="$(echo "$repo" | xargs)"
  title="$(echo "$title" | xargs)"
  subdir="$(echo "${subdir:-}" | xargs)"

  # Build sparse-checkout paths relative to repo root
  if [[ -n "$subdir" ]]; then
    overview_path="${subdir}/OVERVIEW.md"
    docs_path="${subdir}/public-docs/"
  else
    overview_path="OVERVIEW.md"
    docs_path="public-docs/"
  fi

  echo ":: $repo ($overview_path, $docs_path) → src/$slug"

  git clone --depth 1 --filter=blob:none --sparse \
    "${GIT_REMOTE}${repo}.git" "$TMP/$slug" 2>/dev/null
  git -C "$TMP/$slug" sparse-checkout set --no-cone "$overview_path" "$docs_path"

  rm -rf "$SRC/$slug"
  mkdir -p "$SRC/$slug"

  local_overview="$TMP/$slug/$overview_path"
  local_docs="$TMP/$slug/$docs_path"

  [[ -f "$local_overview" ]] &&
    cp "$local_overview" "$SRC/$slug/overview.md"

  if [[ -d "$local_docs" ]]; then
    find "$local_docs" -maxdepth 1 -name "*.md" -exec cp {} "$SRC/$slug/" \;
  fi
done < "$CONF"

# ── Generate SUMMARY.md ──────────────────────────────────────────
extract_title() {
  head -20 "$1" | grep -m1 '^# ' | sed 's/^# //' || basename "$1" .md | tr '-' ' '
}

{
  echo "# Summary"
  echo ""
  echo "[Rubrion Platform](introduction.md)"

  while IFS='|' read -r slug repo title subdir; do
    [[ "$slug" =~ ^[[:space:]]*# || -z "$slug" ]] && continue
    slug="$(echo "$slug" | xargs)"
    title="$(echo "$title" | xargs)"

    echo ""
    echo "# $title"
    echo ""

    # Overview always first
    if [[ -f "$SRC/$slug/overview.md" ]]; then
      echo "- [Overview]($slug/overview.md)"
    fi

    # Remaining pages sorted by filename
    while IFS= read -r f; do
      fname="$(basename "$f")"
      page_title="$(extract_title "$f")"
      echo "- [$page_title]($slug/$fname)"
    done < <(find "$SRC/$slug" -maxdepth 1 -name "*.md" ! -name "overview.md" | sort)

  done < "$CONF"
} > "$SRC/SUMMARY.md"

echo ""
echo ":: Generated SUMMARY.md:"
cat "$SRC/SUMMARY.md"

rm -rf "$TMP"
