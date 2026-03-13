#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
deploy_script="$script_dir/auto-dev-deploy-dev.sh"
preflight_script="$script_dir/auto-dev-preflight.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" == *"$needle"* ]] || fail "Expected output to contain: $needle"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" != *"$needle"* ]] || fail "Did not expect output to contain: $needle"
}

init_git_identity() {
  git config user.name "Test User"
  git config user.email "test@example.com"
}

create_origin_repo() {
  local tmpdir="$1"
  local workdir="$2"
  local origin="$tmpdir/origin.git"

  git init --bare "$origin" >/dev/null
  git clone "$origin" "$workdir" >/dev/null 2>&1
  (
    cd "$workdir"
    init_git_identity
    echo base > README.md
    git add README.md
    git commit -m "base" >/dev/null
    git branch -M main
    git push -u origin main >/dev/null 2>&1
  )
}

write_fake_gh_basic() {
  local tmpdir="$1"
  local bin_dir="$tmpdir/bin"

  mkdir -p "$bin_dir"
  cat > "$bin_dir/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "auth" && "$2" == "status" ]]; then
  exit 0
fi

if [[ "$1" == "workflow" && "$2" == "run" ]]; then
  printf 'gh workflow run %s\n' "$*"
  exit 0
fi

echo "unexpected gh args: $*" >&2
exit 1
EOF
  chmod +x "$bin_dir/gh"
}

test_preflight_requires_explicit_skills_hub_token() {
  local tmpdir
  local workdir
  local output

  tmpdir="$(mktemp -d)"
  workdir="$tmpdir/skills-hub"
  create_origin_repo "$tmpdir" "$workdir"

  output="$(
    cd "$workdir"
    set +e
    AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=1 "$preflight_script" 2>&1
    echo "exit:$?"
  )"
  assert_contains "$output" "Refusing to operate on skills-hub main without the explicit confirmation token."
  assert_contains "$output" "AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=skills-hub-main-confirmed"
  assert_contains "$output" "exit:1"

  output="$(
    cd "$workdir"
    AUTO_DEV_ALLOW_SKILLS_HUB_MAIN=skills-hub-main-confirmed "$preflight_script" 2>&1
  )"
  assert_contains "$output" "AUTO_DEV_REPO_ROOT="
  assert_contains "$output" "AUTO_DEV_BRANCH=main"
}

test_deploy_uses_remote_branch_state_for_inference() {
  local tmpdir
  local workdir
  local infer_script
  local output

  tmpdir="$(mktemp -d)"
  workdir="$tmpdir/work"
  create_origin_repo "$tmpdir" "$workdir"
  write_fake_gh_basic "$tmpdir"

  infer_script="$tmpdir/infer-targets.sh"
  cat > "$infer_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

files="$(paste -sd, -)"
printf 'workflow=infer.yml\n'
printf 'input:files=%s\n' "$files"
EOF
  chmod +x "$infer_script"

  (
    cd "$workdir"
    git checkout -b feature/test >/dev/null
    git push -u origin feature/test >/dev/null 2>&1

    echo remote > remote.txt
    git add remote.txt
    git commit -m "remote change" >/dev/null
    git push >/dev/null 2>&1

    echo local > local.txt
    git add local.txt
    git commit -m "local change" >/dev/null

    output="$(PATH="$tmpdir/bin:$PATH" "$deploy_script" --dry-run --infer-script "$infer_script" 2>&1)"
    assert_contains "$output" "local branch differs from origin/feature/test"
    assert_contains "$output" "Deploy ref: origin/feature/test"
    assert_contains "$output" "Diff base: origin/main"
    assert_contains "$output" "files=remote.txt"
    assert_not_contains "$output" "files=local.txt"
    assert_contains "$output" "Workflow: infer.yml"
  )
}

test_cli_workflow_override_wins_over_infer_script() {
  local tmpdir
  local workdir
  local infer_script
  local output

  tmpdir="$(mktemp -d)"
  workdir="$tmpdir/work"
  create_origin_repo "$tmpdir" "$workdir"
  write_fake_gh_basic "$tmpdir"

  infer_script="$tmpdir/infer-targets.sh"
  cat > "$infer_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

cat >/dev/null
printf 'workflow=infer.yml\n'
printf 'input:deploy_frontend=true\n'
EOF
  chmod +x "$infer_script"

  (
    cd "$workdir"
    git checkout -b feature/test >/dev/null
    git push -u origin feature/test >/dev/null 2>&1

    mkdir -p frontend
    echo app > frontend/app.txt
    git add frontend/app.txt
    git commit -m "frontend change" >/dev/null
    git push >/dev/null 2>&1

    output="$(PATH="$tmpdir/bin:$PATH" "$deploy_script" --dry-run --infer-script "$infer_script" --workflow manual.yml 2>&1)"
    assert_contains "$output" "Ignoring infer workflow override because the workflow was set explicitly: infer.yml"
    assert_contains "$output" "Workflow: manual.yml"
    assert_not_contains "$output" "Workflow: infer.yml"
    assert_contains "$output" "gh   workflow   run   manual.yml"
  )
}

test_wait_tracks_newly_dispatched_run() {
  local tmpdir
  local workdir
  local infer_script
  local state_dir
  local watched_run_id

  tmpdir="$(mktemp -d)"
  workdir="$tmpdir/work"
  state_dir="$tmpdir/state"
  mkdir -p "$state_dir"
  create_origin_repo "$tmpdir" "$workdir"

  infer_script="$tmpdir/infer-targets.sh"
  cat > "$infer_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

cat >/dev/null
printf 'input:deploy_backend=true\n'
EOF
  chmod +x "$infer_script"

  mkdir -p "$tmpdir/bin"
  cat > "$tmpdir/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state_dir="${GH_FAKE_STATE_DIR:?}"

if [[ "$1" == "auth" && "$2" == "status" ]]; then
  exit 0
fi

if [[ "$1" == "workflow" && "$2" == "run" ]]; then
  : > "$state_dir/dispatched"
  exit 0
fi

if [[ "$1" == "run" && "$2" == "list" ]]; then
  if [[ -f "$state_dir/dispatched" ]]; then
    printf '41\n99\n'
  else
    printf '41\n'
  fi
  exit 0
fi

if [[ "$1" == "run" && "$2" == "watch" ]]; then
  printf '%s' "$3" > "$state_dir/watched_run_id"
  exit 0
fi

echo "unexpected gh args: $*" >&2
exit 1
EOF
  chmod +x "$tmpdir/bin/gh"

  (
    cd "$workdir"
    git checkout -b feature/test >/dev/null
    git push -u origin feature/test >/dev/null 2>&1

    mkdir -p backend
    echo api > backend/app.txt
    git add backend/app.txt
    git commit -m "backend change" >/dev/null
    git push >/dev/null 2>&1

    GH_FAKE_STATE_DIR="$state_dir" PATH="$tmpdir/bin:$PATH" "$deploy_script" --infer-script "$infer_script" --wait --timeout 10 >/dev/null 2>&1
  )

  watched_run_id="$(cat "$state_dir/watched_run_id")"
  [[ "$watched_run_id" == "99" ]] || fail "Expected wait logic to watch run 99, got ${watched_run_id:-<empty>}"
}

test_preflight_requires_explicit_skills_hub_token
test_deploy_uses_remote_branch_state_for_inference
test_cli_workflow_override_wins_over_infer_script
test_wait_tracks_newly_dispatched_run

echo "PASS"
