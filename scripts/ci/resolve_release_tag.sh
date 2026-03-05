#!/usr/bin/env bash
set -euo pipefail

_main() {
  local event_name="${1}"
  local input_release_tag="${2}"
  local github_ref_name="${3}"
  local output_path="${4}"

  local release_tag=""
  if [[ "${event_name}" == "workflow_dispatch" ]]; then
    release_tag="${input_release_tag}"
  else
    release_tag="${github_ref_name}"
  fi

  if [[ ! "${release_tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "::error title=Invalid release tag::Expected X.Y.Z, got '${release_tag}'"
    exit 1
  fi

  echo "release_tag=${release_tag}" >> "${output_path}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _main "$@"
fi
