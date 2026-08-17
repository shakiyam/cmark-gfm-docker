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
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

if ! OUTPUT=$(echo '# Hello' | $CONTAINER_ENGINE container run \
  --name "test_cmark_gfm_$(uuidgen | head -c8)" \
  --rm \
  --pull=never \
  -i \
  "${ENGINE_OPTS[@]}" \
  "$IMAGE_NAME"); then
  echo_error 'Test failed: cmark-gfm exited with a non-zero status.'
  exit 1
fi
readonly OUTPUT

if [[ "$OUTPUT" != '<h1>Hello</h1>' ]]; then
  echo_error 'Test failed: unexpected output.'
  echo "$OUTPUT"
  exit 1
fi

echo_success 'Test passed: cmark-gfm converted Markdown to HTML successfully.'
