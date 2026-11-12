#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

IMAGE_NAME=ghcr.io/shakiyam/cmark-gfm
readonly IMAGE_NAME

if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  # The image runs as USER 65534, which rootless Podman maps to a subuid that cannot
  # read the caller's private files; keep-id plus -u runs as the caller instead.
  ENGINE_OPTS=(--security-opt label=disable --userns=keep-id -u "$(id -u):$(id -g)")
fi
readonly ENGINE_OPTS

# The wrapper is tested as a standalone copy, as installed by users
WORK_DIR=$(mktemp -d)
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT
cp "$SCRIPT_DIR"/cmark-gfm "$WORK_DIR"/
echo '# Hello' >"$WORK_DIR"/test.md

run_test() {
  local -r name=$1
  shift
  local output
  if ! output=$("$@"); then
    echo_error "Test failed: $name exited with a non-zero status."
    exit 1
  fi
  if [[ "$output" != '<h1>Hello</h1>' ]]; then
    echo_error "Test failed: $name produced unexpected output."
    echo "$output"
    exit 1
  fi
  echo_success "Test passed: $name"
}

image_with_stdin() {
  echo '# Hello' | $CONTAINER_ENGINE container run \
    --name "test_cmark_gfm_$(uuidgen | head -c8)" \
    --rm \
    --pull=never \
    -i \
    "${ENGINE_OPTS[@]}" \
    "$IMAGE_NAME"
}

wrapper_with_stdin() {
  (cd "$WORK_DIR" && echo '# Hello' | ./cmark-gfm)
}

wrapper_with_file() {
  (cd "$WORK_DIR" && ./cmark-gfm test.md)
}

test_image_runs_as_nobody() {
  local output
  # ENGINE_OPTS is omitted because its -u would override the image's default user
  if ! output=$($CONTAINER_ENGINE container run \
    --name "test_cmark_gfm_$(uuidgen | head -c8)" \
    --rm \
    --pull=never \
    --entrypoint id \
    "$IMAGE_NAME"); then
    echo_error 'Test failed: image default user could not be determined.'
    exit 1
  fi
  if [[ "$output" != 'uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)' ]]; then
    echo_error 'Test failed: image does not run as nobody:nogroup by default.'
    echo "$output"
    exit 1
  fi
  echo_success 'Test passed: image runs as nobody'
}

test_image_runs_as_nobody
run_test 'image with stdin' image_with_stdin
run_test 'wrapper with stdin' wrapper_with_stdin
run_test 'wrapper with file' wrapper_with_file
