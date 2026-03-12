#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  fetch_with_jina_fallback.sh <url> [output_file]

Behavior:
  1) Try direct fetch first.
  2) If direct fetch fails or content looks blocked, retry via jina.ai proxy.

Environment variables:
  FETCH_TIMEOUT          Total request timeout in seconds (default: 25)
  FETCH_CONNECT_TIMEOUT  Connect timeout in seconds (default: 10)
  FETCH_MIN_BYTES        Treat direct fetch as blocked if below bytes (default: 800)
  JINA_FORCE             If set to 1, skip direct fetch and always use jina.ai
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "" ]]; then
  usage
  exit 0
fi

url="$1"
output_file="${2:-}"

timeout_s="${FETCH_TIMEOUT:-25}"
connect_timeout_s="${FETCH_CONNECT_TIMEOUT:-10}"
min_bytes="${FETCH_MIN_BYTES:-800}"
force_jina="${JINA_FORCE:-0}"
ua="${FETCH_USER_AGENT:-Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36}"

tmp_file="$(mktemp)"
tmp_err="$(mktemp)"
cleanup() {
  rm -f "$tmp_file" "$tmp_err"
}
trap cleanup EXIT

fetch_url() {
  local target_url="$1"
  if ! curl -L --silent --show-error --fail \
    --max-time "$timeout_s" \
    --connect-timeout "$connect_timeout_s" \
    -A "$ua" \
    "$target_url" \
    -o "$tmp_file" \
    2>"$tmp_err"; then
    return 1
  fi
  return 0
}

looks_blocked() {
  local bytes
  bytes="$(wc -c <"$tmp_file" | tr -d ' ')"
  if [[ "$bytes" -eq 0 ]]; then
    return 0
  fi

  # Detect common blocked/login wall markers.
  if grep -Eiq \
    "enable javascript|captcha|verify you are human|access denied|forbidden|cloudflare|just a moment|don't miss what's happening|log in|sign up|please wait while we check your browser" \
    "$tmp_file"; then
    return 0
  fi

  # Optional small-page heuristic: only treat as blocked when content looks like
  # a thin shell page (html/script heavy) without normal article/paragraph text.
  if [[ "$min_bytes" -gt 0 && "$bytes" -lt "$min_bytes" ]]; then
    if grep -Eiq "<html|<!doctype|<body|<script" "$tmp_file" \
      && ! grep -Eiq "<article|<main|<p>" "$tmp_file"; then
      return 0
    fi
  fi

  return 1
}

to_jina_url() {
  local original="$1"
  if [[ "$original" =~ ^https?://r\.jina\.ai/ ]]; then
    printf '%s\n' "$original"
    return 0
  fi
  if [[ ! "$original" =~ ^https?:// ]]; then
    echo "ERROR: URL must start with http:// or https:// : $original" >&2
    return 1
  fi

  local no_scheme="${original#http://}"
  no_scheme="${no_scheme#https://}"
  printf 'https://r.jina.ai/http://%s\n' "$no_scheme"
}

write_output() {
  local source="$1"
  if [[ -n "$output_file" ]]; then
    mkdir -p "$(dirname "$output_file")"
    cp "$tmp_file" "$output_file"
    echo "saved=$output_file" >&2
  else
    cat "$tmp_file"
  fi
  echo "source=$source" >&2
}

if [[ "$force_jina" == "1" ]]; then
  jina_url="$(to_jina_url "$url")"
  fetch_url "$jina_url" || {
    echo "ERROR: jina fetch failed: $jina_url" >&2
    cat "$tmp_err" >&2
    exit 1
  }
  write_output "jina"
  exit 0
fi

if fetch_url "$url"; then
  if looks_blocked; then
    jina_url="$(to_jina_url "$url")"
    if fetch_url "$jina_url"; then
      write_output "jina"
      exit 0
    fi
    echo "ERROR: direct fetch looked blocked and jina fallback failed." >&2
    cat "$tmp_err" >&2
    exit 1
  fi

  write_output "direct"
  exit 0
fi

jina_url="$(to_jina_url "$url")"
if fetch_url "$jina_url"; then
  write_output "jina"
  exit 0
fi

echo "ERROR: both direct and jina fetch failed for URL: $url" >&2
cat "$tmp_err" >&2
exit 1
