#!/bin/sh

set -eu

if ! git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"; then
  echo "resolve-project-path.sh: not inside a git repository" >&2
  exit 1
fi

project_path="$(dirname "$git_common_dir")"

if [ ! -d "$project_path" ]; then
  echo "resolve-project-path.sh: resolved project path does not exist: $project_path" >&2
  exit 1
fi

printf '%s\n' "$project_path"
