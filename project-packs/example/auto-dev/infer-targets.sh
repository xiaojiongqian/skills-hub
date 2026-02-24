#!/usr/bin/env bash
# Example: infer deploy targets from changed files
# Copy this file and adapt the case patterns to your project's module structure.
set -euo pipefail

changed_files=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  changed_files+=("$line")
done

# Example: map file paths to deploy flags
deploy_frontend=false
deploy_backend=false

for file in "${changed_files[@]}"; do
  case "$file" in
    frontend/*|client/*|src/*)
      deploy_frontend=true
      ;;
    backend/*|server/*|api/*)
      deploy_backend=true
      ;;
  esac
done

echo "workflow=deploy.yml"
echo "input:deploy_frontend=$deploy_frontend"
echo "input:deploy_backend=$deploy_backend"
