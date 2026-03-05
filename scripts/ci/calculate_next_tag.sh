#!/usr/bin/env bash
set -euo pipefail

_main() {
  local bump="${1}"
  local output_path="${2}"

  local latest_tag
  latest_tag="$(git tag --list '[0-9]*.[0-9]*.[0-9]*' --sort=-version:refname | head -n 1)"
  if [[ -z "${latest_tag}" ]]; then
    latest_tag='0.0.0'
  fi

  if [[ ! "${latest_tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "::error title=Invalid latest tag::Latest matching tag '${latest_tag}' is not strict semver X.Y.Z"
    exit 1
  fi

  local major minor patch
  IFS='.' read -r major minor patch <<< "${latest_tag}"

  case "${bump}" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
    *)
      echo "::error title=Invalid bump input::Unsupported bump '${bump}'"
      exit 1
      ;;
  esac

  local next_tag="${major}.${minor}.${patch}"
  if git rev-parse --verify --quiet "refs/tags/${next_tag}" >/dev/null; then
    echo "::error title=Tag already exists::Tag '${next_tag}' already exists"
    exit 1
  fi

  echo "latest_tag=${latest_tag}" >> "${output_path}"
  echo "next_tag=${next_tag}" >> "${output_path}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _main "$@"
fi
