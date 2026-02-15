#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

eval "$("$script_dir/auto-dev-preflight.sh")"
cd "$AUTO_DEV_REPO_ROOT"

usage() {
  cat <<'USAGE'
Usage: auto-dev-deploy-dev.sh [--wait] [--timeout <seconds>] [--dry-run] [--setup-cloud-tasks] [--force-all]
USAGE
}

wait_for_run=false
timeout_seconds=900
dry_run=false
setup_cloud_tasks=false
force_all=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait)
      wait_for_run=true
      ;;
    --timeout)
      timeout_seconds="$2"
      shift
      ;;
    --dry-run)
      dry_run=true
      ;;
    --setup-cloud-tasks)
      setup_cloud_tasks=true
      ;;
    --force-all)
      force_all=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required. Install and authenticate first." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  echo "No upstream configured. Push the current branch first:" >&2
  echo "  git push -u origin $AUTO_DEV_BRANCH" >&2
  exit 1
fi

get_changed_files() {
  local upstream base
  if upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"; then
    base="$(git merge-base HEAD "$upstream")"
    git diff --name-only "$base" HEAD
    return
  fi

  if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
    git diff --name-only HEAD~1 HEAD
    return
  fi

  git diff --name-only
}

changed_files=()
while IFS= read -r line; do
  changed_files+=("$line")
done < <(get_changed_files)

if (( ${#changed_files[@]} == 0 )) && [[ "$force_all" == "false" ]]; then
  echo "No changes detected to infer deploy targets." >&2
  exit 1
fi

deploy_client=false
deploy_functions_web_account=false
deploy_functions_web_reports=false
deploy_functions_web_content=false
deploy_func_core=false
deploy_portal=false
deploy_firestore=false
deploy_storage=false
functions_web_all=false

if [[ "$force_all" == "true" ]]; then
  deploy_client=true
  deploy_functions_web_account=true
  deploy_functions_web_reports=true
  deploy_functions_web_content=true
  deploy_func_core=true
  deploy_portal=true
  deploy_firestore=true
  deploy_storage=true
else
  for file in "${changed_files[@]}"; do
    case "$file" in
      client/*)
        deploy_client=true
        ;;
      portal/*)
        deploy_portal=true
        ;;
      func-core/*)
        deploy_func_core=true
        ;;
      firestore.rules|firestore.indexes*.json)
        deploy_firestore=true
        ;;
      storage.rules)
        deploy_storage=true
        ;;
      config/environments.json)
        deploy_client=true
        functions_web_all=true
        ;;
      config/functions-web-groups.json)
        functions_web_all=true
        ;;
      firebase.json|.firebaserc)
        deploy_client=true
        deploy_func_core=true
        functions_web_all=true
        ;;
      functions-web/*)
        case "$file" in
          functions-web/business/*)
            subpath="${file#functions-web/business/}"
            subdir="${subpath%%/*}"
            case "$subdir" in
              stripe|orders|order|credits|users)
                deploy_functions_web_account=true
                ;;
              share|featured|monitoring|analysis)
                deploy_functions_web_reports=true
                ;;
              tales|public|review|spaces|fcm|tags)
                deploy_functions_web_content=true
                ;;
              *)
                functions_web_all=true
                ;;
            esac
            ;;
          functions-web/utils/*|functions-web/config.js|functions-web/index.js|functions-web/lib/*|functions-web/package*.json|functions-web/.env*|functions-web/test/*)
            functions_web_all=true
            ;;
          *)
            functions_web_all=true
            ;;
        esac
        ;;
    esac
  done
fi

if [[ "$functions_web_all" == "true" ]]; then
  deploy_functions_web_account=true
  deploy_functions_web_reports=true
  deploy_functions_web_content=true
fi

if [[ "$deploy_client" == "false" &&
      "$deploy_functions_web_account" == "false" &&
      "$deploy_functions_web_reports" == "false" &&
      "$deploy_functions_web_content" == "false" &&
      "$deploy_func_core" == "false" &&
      "$deploy_portal" == "false" &&
      "$deploy_firestore" == "false" &&
      "$deploy_storage" == "false" ]]; then
  echo "No deploy targets inferred from changes." >&2
  printf 'Changed files:\n' >&2
  printf '  %s\n' "${changed_files[@]}" >&2
  exit 1
fi

printf 'Deploy inputs:\n'
printf '  deploy_client=%s\n' "$deploy_client"
printf '  deploy_functions_web_account=%s\n' "$deploy_functions_web_account"
printf '  deploy_functions_web_reports=%s\n' "$deploy_functions_web_reports"
printf '  deploy_functions_web_content=%s\n' "$deploy_functions_web_content"
printf '  deploy_func_core=%s\n' "$deploy_func_core"
printf '  deploy_portal=%s\n' "$deploy_portal"
printf '  deploy_firestore=%s\n' "$deploy_firestore"
printf '  deploy_storage=%s\n' "$deploy_storage"
printf '  setup_cloud_tasks=%s\n' "$setup_cloud_tasks"

cmd=(
  gh workflow run dev.yml
  --ref "$AUTO_DEV_BRANCH"
  -f "deploy_client=$deploy_client"
  -f "deploy_functions_web_account=$deploy_functions_web_account"
  -f "deploy_functions_web_reports=$deploy_functions_web_reports"
  -f "deploy_functions_web_content=$deploy_functions_web_content"
  -f "deploy_func_core=$deploy_func_core"
  -f "deploy_portal=$deploy_portal"
  -f "deploy_firestore=$deploy_firestore"
  -f "deploy_storage=$deploy_storage"
  -f "setup_cloud_tasks=$setup_cloud_tasks"
)

if [[ "$dry_run" == "true" ]]; then
  printf 'Dry run command:\n'
  printf '  %q ' "${cmd[@]}"
  printf '\n'
  exit 0
fi

"${cmd[@]}"

if [[ "$wait_for_run" == "true" ]]; then
  sleep 3
  run_id="$(gh run list --workflow dev.yml --branch "$AUTO_DEV_BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')"
  if [[ -n "$run_id" && "$run_id" != "null" ]]; then
    gh run watch "$run_id" --interval 10 --exit-status
  else
    echo "Unable to find the workflow run to watch." >&2
    exit 1
  fi
fi
