#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

SEMVER_REGEX="^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-|_)?([0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

PROG=semver

USAGE="\
Usage:
  $PROG compare <version> <other_version>
  $PROG --help

Arguments:
  <version>  A version must match the following regex pattern:
             \"${SEMVER_REGEX}\".
             In english, the version must match X.Y.Z(-PRERELEASE)(+BUILD)
             where X, Y and Z are positive integers, PRERELEASE is an optionnal
             string composed of alphanumeric characters and hyphens and
             BUILD is also an optional string composed of alphanumeric
             characters and hyphens.

  <other_version>  See <version> definition.

Options:
  -h, --help             Print this help message.

Commands:
  compare  Compare <version> with <other_version>, output to stdout the
           following values: -1 if <other_version> is newer, 0 if equal, 1 if
           older."


function error {
  echo -e "$1" >&2
  exit 1
}

function usage-help {
  error "$USAGE"
}

function validate-version {
  local version=$1
  if [[ "$version" =~ $SEMVER_REGEX ]]; then
    # if a second argument is passed, store the result in var named by $2
    if [ "$#" -eq "2" ]; then
      local major=${BASH_REMATCH[1]}
      local minor=${BASH_REMATCH[2]}
      local patch=${BASH_REMATCH[3]}
      local prere=${BASH_REMATCH[4]}
      local build=${BASH_REMATCH[5]}
      eval "$2=(\"$major\" \"$minor\" \"$patch\" \"$prere\" \"$build\")"
    else
      echo "$version"
    fi
  else
    error "version $version does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'. See help for more information."
  fi
}

function compare-version {
  validate-version "$1" V
  validate-version "$2" V_

  # MAJOR, MINOR and PATCH should compare numericaly
  for i in 0 1 2; do
    local diff=$((${V[$i]} - ${V_[$i]}))
    if [[ $diff -lt 0 ]]; then
      echo -1; return 0
    elif [[ $diff -gt 0 ]]; then
      echo 1; return 0
    fi
  done

  # PREREL should compare with the ASCII order.
  if [[ -z "${V[3]}" ]] && [[ -n "${V_[3]}" ]]; then
    echo -1; return 0;
  elif [[ -n "${V[3]}" ]] && [[ -z "${V_[3]}" ]]; then
    echo 1; return 0;
  elif [[ -n "${V[3]}" ]] && [[ -n "${V_[3]}" ]]; then
    if [[ "${V[3]}" > "${V_[3]}" ]]; then
      echo 1; return 0;
    elif [[ "${V[3]}" < "${V_[3]}" ]]; then
      echo -1; return 0;
    fi
  fi

  echo 0
}

function command-compare {
  local v; local v_;

  case $# in
    2) v=$(validate-version "$1"); v_=$(validate-version "$2") ;;
    *) usage-help ;;
  esac

  compare-version "$v" "$v_"
  exit 0
}

case $# in
  0) echo "Unknown command: $*"; usage-help;;
esac

case $1 in
  --help|-h) echo -e "$USAGE"; exit 0;;
  compare) shift; command-compare "$@";;
  *) echo "Unknown arguments: $*"; usage-help;;
esac
