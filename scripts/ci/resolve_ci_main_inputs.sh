#!/usr/bin/env bash
set -euo pipefail

_main() {
  local event_name="${1}"
  local input_build_tag="${2}"
  local input_publish="${3}"
  local github_sha="${4}"
  local output_path="${5}"

  local build_tag="${github_sha}"
  if [[ "${event_name}" == "workflow_dispatch" || "${event_name}" == "workflow_call" ]]; then
    if [[ -n "${input_build_tag}" ]]; then
      build_tag="${input_build_tag}"
    fi
  fi

  local publish="false"
  if [[ "${event_name}" == "push" ]]; then
    publish="true"
  elif [[ "${event_name}" == "workflow_dispatch" || "${event_name}" == "workflow_call" ]]; then
    publish="${input_publish}"
  fi

  echo "build_tag=${build_tag}" >> "${output_path}"
  echo "publish=${publish}" >> "${output_path}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _main "$@"
fi
