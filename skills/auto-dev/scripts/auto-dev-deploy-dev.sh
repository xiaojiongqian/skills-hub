#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: auto-dev-deploy-dev.sh [options]

Options:
  --wait                       wait for the dispatched workflow run to finish
  --timeout <seconds>          watch timeout when --wait is enabled (default: 900)
  --dry-run                    print gh workflow command without running it
  --force-all                  tell inference layer to deploy all relevant targets
  --setup-cloud-tasks          request setup_cloud_tasks=true when supported
  --diff-base <ref>            git ref used to compute changed files (default: origin/main or origin/HEAD)
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
diff_base="${AUTO_DEV_DIFF_BASE:-}"
workflow="dev.yml"
workflow_locked=false
if [[ -n "${AUTO_DEV_WORKFLOW:-}" ]]; then
  workflow="${AUTO_DEV_WORKFLOW}"
  workflow_locked=true
fi
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
    --diff-base)
      diff_base="$2"
      shift
      ;;
    --infer-script)
      infer_script="$2"
      shift
      ;;
    --workflow)
      workflow="$2"
      workflow_locked=true
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

if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  echo "No upstream configured. Push the current branch first:" >&2
  echo "  git push -u origin $AUTO_DEV_BRANCH" >&2
  exit 1
fi

upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}')"
expected_upstream="origin/$AUTO_DEV_BRANCH"
if [[ "$upstream_ref" != "$expected_upstream" ]]; then
  echo "Deploy safety check failed: current branch must track $expected_upstream, found $upstream_ref." >&2
  echo "Set the upstream to origin/$AUTO_DEV_BRANCH before dispatching workflows for this branch." >&2
  exit 1
fi

deploy_ref="$upstream_ref"
deploy_sha="$(git rev-parse "$deploy_ref")"

ahead_count=0
behind_count=0
read -r ahead_count behind_count < <(git rev-list --left-right --count HEAD..."$deploy_ref")
if (( ahead_count > 0 || behind_count > 0 )); then
  echo "Warning: local branch differs from $deploy_ref (ahead $ahead_count, behind $behind_count); deploy inference and workflow dispatch use the remote ref only." >&2
fi

resolve_diff_base() {
  local origin_head_ref

  if [[ -n "$diff_base" ]]; then
    if git rev-parse --verify "${diff_base}^{commit}" >/dev/null 2>&1; then
      printf '%s\n' "$diff_base"
      return 0
    fi

    echo "Diff base not found: $diff_base" >&2
    return 1
  fi

  if git rev-parse --verify "origin/main^{commit}" >/dev/null 2>&1; then
    printf 'origin/main\n'
    return 0
  fi

  if origin_head_ref="$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"; then
    origin_head_ref="${origin_head_ref#refs/remotes/}"
    if git rev-parse --verify "${origin_head_ref}^{commit}" >/dev/null 2>&1; then
      printf '%s\n' "$origin_head_ref"
      return 0
    fi
  fi

  echo "Unable to resolve a diff base. Pass --diff-base or set AUTO_DEV_DIFF_BASE." >&2
  return 1
}

diff_base="$(resolve_diff_base)"
diff_merge_base="$(git merge-base "$diff_base" "$deploy_ref")"

get_changed_files() {
  local base
  base="$diff_merge_base"
  git diff --name-only "$base" "$deploy_ref"
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
      input_pairs[i]="$key=$value"
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
    AUTO_DEV_DEPLOY_REF="$deploy_ref" \
    AUTO_DEV_DEPLOY_SHA="$deploy_sha" \
    AUTO_DEV_DIFF_BASE="$diff_base" \
    AUTO_DEV_DIFF_MERGE_BASE="$diff_merge_base" \
    "$infer_script" < "$changed_tmp"
  })"

  while IFS= read -r raw_line; do
    line="${raw_line%%$'\r'}"
    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue

    if [[ "$line" == workflow=* ]]; then
      if [[ "$workflow_locked" == "true" ]]; then
        echo "Ignoring infer workflow override because the workflow was set explicitly: ${line#workflow=}" >&2
      else
        workflow="${line#workflow=}"
      fi
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
printf 'Deploy ref: %s (%s)\n' "$deploy_ref" "$deploy_sha"
printf 'Diff base: %s\n' "$diff_base"
printf 'Deploy inputs:\n'
for pair in "${input_pairs[@]}"; do
  printf '  %s\n' "$pair"
done

contains_line() {
  local needle="$1"
  local haystack="$2"
  local line

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" == "$needle" ]]; then
      return 0
    fi
  done <<<"$haystack"

  return 1
}

list_matching_run_ids() {
  gh run list \
    --workflow "$workflow" \
    --branch "$AUTO_DEV_BRANCH" \
    --event workflow_dispatch \
    --limit 50 \
    --json databaseId,headSha \
    --jq ".[] | select(.headSha == \"$deploy_sha\") | .databaseId"
}

cmd=(
  gh workflow run "$workflow"
  --ref "$AUTO_DEV_BRANCH"
)
for pair in "${input_pairs[@]}"; do
  cmd+=( -f "$pair" )
done

previous_run_ids=""
if [[ "$wait_for_run" == "true" ]]; then
  previous_run_ids="$(list_matching_run_ids || true)"
fi

if [[ "$dry_run" == "true" ]]; then
  printf 'Dry run command:\n'
  printf '  %q ' "${cmd[@]}"
  printf '\n'
  exit 0
fi

"${cmd[@]}"

if [[ "$wait_for_run" == "true" ]]; then
  watch_deadline=$((SECONDS + timeout_seconds))
  run_id=""

  # Match on a new workflow_dispatch run for the dispatched commit instead of the latest run on the branch.
  while (( SECONDS < watch_deadline )); do
    candidate_run_ids="$(list_matching_run_ids || true)"
    while IFS= read -r candidate_run_id; do
      [[ -z "$candidate_run_id" ]] && continue
      if ! contains_line "$candidate_run_id" "$previous_run_ids"; then
        run_id="$candidate_run_id"
        break 2
      fi
    done <<<"$candidate_run_ids"
    sleep 3
  done

  if [[ -z "$run_id" || "$run_id" == "null" ]]; then
    echo "Unable to find the workflow run to watch." >&2
    exit 1
  fi

  remaining_timeout=$((watch_deadline - SECONDS))
  if (( remaining_timeout <= 0 )); then
    echo "Timed out before the workflow run became available to watch." >&2
    exit 1
  fi

  if command -v timeout >/dev/null 2>&1; then
    timeout "$remaining_timeout" gh run watch "$run_id" --interval 10 --exit-status
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$remaining_timeout" gh run watch "$run_id" --interval 10 --exit-status
  else
    gh run watch "$run_id" --interval 10 --exit-status
  fi
fi
