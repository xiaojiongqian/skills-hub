#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: auto-dev-deploy-dev.sh [options]

Options:
  --wait                       wait for the latest workflow run to finish
  --timeout <seconds>          watch timeout when --wait is enabled (default: 900)
  --dry-run                    print gh workflow command without running it
  --force-all                  tell inference layer to deploy all relevant targets
  --setup-cloud-tasks          request setup_cloud_tasks=true when supported
  --infer-script <path>        path to project-specific target inference script
  --workflow <name>            workflow file name (default: dev.yml)
  --set <key=value>            add/override workflow input (repeatable)
  -h, --help                   show this help
USAGE
}

wait_for_run=false
timeout_seconds=900
dry_run=false
force_all=false
setup_cloud_tasks=false
infer_script="${AUTO_DEV_INFER_SCRIPT:-}"
workflow="${AUTO_DEV_WORKFLOW:-dev.yml}"
manual_inputs=()

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
    --force-all)
      force_all=true
      ;;
    --setup-cloud-tasks)
      setup_cloud_tasks=true
      ;;
    --infer-script)
      infer_script="$2"
      shift
      ;;
    --workflow)
      workflow="$2"
      shift
      ;;
    --set)
      manual_inputs+=("$2")
      shift
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

eval "$("$script_dir/auto-dev-preflight.sh")"
cd "$AUTO_DEV_REPO_ROOT"

if [[ -z "$infer_script" && -f "$AUTO_DEV_REPO_ROOT/.skills-hub/auto-dev/infer-targets.sh" ]]; then
  infer_script="$AUTO_DEV_REPO_ROOT/.skills-hub/auto-dev/infer-targets.sh"
fi

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
  local upstream
  local base
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
  [[ -z "$line" ]] && continue
  changed_files+=("$line")
done < <(get_changed_files)

if (( ${#changed_files[@]} == 0 )) && [[ "$force_all" == "false" ]]; then
  echo "No changes detected to infer deploy targets." >&2
  exit 1
fi

input_pairs=()

set_input() {
  local key="$1"
  local value="$2"
  local i
  local pair
  local existing_key

  if [[ -z "$key" ]]; then
    echo "Invalid input key." >&2
    exit 1
  fi

  for i in "${!input_pairs[@]}"; do
    pair="${input_pairs[$i]}"
    existing_key="${pair%%=*}"
    if [[ "$existing_key" == "$key" ]]; then
      input_pairs[$i]="$key=$value"
      return
    fi
  done

  input_pairs+=("$key=$value")
}

has_input() {
  local key="$1"
  local pair
  local existing_key

  for pair in "${input_pairs[@]}"; do
    existing_key="${pair%%=*}"
    if [[ "$existing_key" == "$key" ]]; then
      return 0
    fi
  done

  return 1
}

parse_input_assignment() {
  local assignment="$1"
  local key
  local value

  if [[ "$assignment" != *=* ]]; then
    echo "Invalid input value: $assignment (expected key=value)" >&2
    exit 1
  fi

  key="${assignment%%=*}"
  value="${assignment#*=}"
  set_input "$key" "$value"
}

if [[ -n "$infer_script" ]]; then
  if [[ ! -x "$infer_script" ]]; then
    echo "Infer script is not executable: $infer_script" >&2
    exit 1
  fi

  changed_tmp="$(mktemp)"
  trap 'rm -f "$changed_tmp"' EXIT
  : > "$changed_tmp"
  if (( ${#changed_files[@]} > 0 )); then
    printf '%s\n' "${changed_files[@]}" > "$changed_tmp"
  fi

  infer_output="$({
    AUTO_DEV_FORCE_ALL=$([[ "$force_all" == "true" ]] && echo 1 || echo 0) \
    AUTO_DEV_SETUP_CLOUD_TASKS=$([[ "$setup_cloud_tasks" == "true" ]] && echo 1 || echo 0) \
    "$infer_script" < "$changed_tmp"
  })"

  while IFS= read -r raw_line; do
    line="${raw_line%%$'\r'}"
    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue

    if [[ "$line" == workflow=* ]]; then
      workflow="${line#workflow=}"
      continue
    fi

    if [[ "$line" == input:* ]]; then
      parse_input_assignment "${line#input:}"
      continue
    fi

    if [[ "$line" == *=* ]]; then
      parse_input_assignment "$line"
      continue
    fi

    echo "Unrecognized infer output line: $line" >&2
    exit 1
  done <<<"$infer_output"
fi

if [[ "$setup_cloud_tasks" == "true" ]] && has_input "setup_cloud_tasks"; then
  set_input "setup_cloud_tasks" "true"
fi

if (( ${#manual_inputs[@]} > 0 )); then
  for assignment in "${manual_inputs[@]}"; do
    parse_input_assignment "$assignment"
  done
fi

if (( ${#input_pairs[@]} == 0 )); then
  echo "No workflow inputs resolved." >&2
  if [[ -z "$infer_script" ]]; then
    echo "Hint: provide --infer-script or set AUTO_DEV_INFER_SCRIPT." >&2
  fi
  printf 'Changed files:\n' >&2
  if (( ${#changed_files[@]} > 0 )); then
    printf '  %s\n' "${changed_files[@]}" >&2
  fi
  exit 1
fi

printf 'Workflow: %s\n' "$workflow"
printf 'Deploy inputs:\n'
for pair in "${input_pairs[@]}"; do
  printf '  %s\n' "$pair"
done

cmd=(
  gh workflow run "$workflow"
  --ref "$AUTO_DEV_BRANCH"
)
for pair in "${input_pairs[@]}"; do
  cmd+=( -f "$pair" )
done

if [[ "$dry_run" == "true" ]]; then
  printf 'Dry run command:\n'
  printf '  %q ' "${cmd[@]}"
  printf '\n'
  exit 0
fi

"${cmd[@]}"

if [[ "$wait_for_run" == "true" ]]; then
  sleep 3
  run_id="$(gh run list --workflow "$workflow" --branch "$AUTO_DEV_BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')"
  if [[ -z "$run_id" || "$run_id" == "null" ]]; then
    echo "Unable to find the workflow run to watch." >&2
    exit 1
  fi

  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_seconds" gh run watch "$run_id" --interval 10 --exit-status
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$timeout_seconds" gh run watch "$run_id" --interval 10 --exit-status
  else
    gh run watch "$run_id" --interval 10 --exit-status
  fi
fi
