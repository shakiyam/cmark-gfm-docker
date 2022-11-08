#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $# -ne 3 ]]; then
  echo_error "Usage: check_for_new_release.sh software_name repository current_release"
  exit 1
fi

readonly SOFTWARE_NAME=$1
readonly REPOSITORY=$2
readonly CURRENT_RELEASE=$3
LATEST_RELEASE=$(
  curl -sSI "https://github.com/$REPOSITORY/releases/latest" \
    | tr -d '\r' \
    | awk -F'/' '/^[Ll]ocation:/{print $NF}'
)
readonly LATEST_RELEASE
if [[ "$CURRENT_RELEASE" != "$LATEST_RELEASE" ]]; then
  echo_warn "$SOFTWARE_NAME $CURRENT_RELEASE is not the latest release. The latest release is $LATEST_RELEASE."
  exit 2
fi
echo_success "$SOFTWARE_NAME $CURRENT_RELEASE is the latest release."
