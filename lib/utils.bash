#!/usr/bin/env bash

set -euo pipefail

current_script_path=${BASH_SOURCE[0]}
plugin_dir=$(dirname "$(dirname "$current_script_path")")

# shellcheck source=../lib/versions.bash
source "${plugin_dir}/lib/versions.bash"

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for glab.
GH_REPO="https://github.com/profclems/glab"
GL_REPO="https://gitlab.com/gitlab-org/cli"
TOOL_NAME="glab"
TOOL_TEST="glab version"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# starting with 1.47.0, the archive name OS name and architecture changes
ARCHIVE_CHANGE_VERSION="1.47.0"

# NOTE: You might want to remove this if glab is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_tags() {
  local all_tags github_tags gitlab_tags

  github_tags="$(git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//')"

  gitlab_tags="$(git ls-remote --tags --refs "${GL_REPO}.git" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//')"

  # some tags overlap between github and gitlab, so dedup them
  all_tags=$(printf "%s\n%s" "$github_tags" "$gitlab_tags" | sort | uniq)

  echo "$all_tags"
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if glab has other means of determining installable versions.
  list_tags
}

download_release() {
  local version filename url os arch cutoff_version compare_result
  version="$1"
  filename="$2"
  os=$(get_os "$version")
  arch=$(get_arch "$version")
  cutoff_version="1.23.0"

  # download from github if prior to version $cutoff_version
  compare_versions "$version" "$cutoff_version" || compare_result=$?
  if [ $compare_result -eq 1 ]; then # 1 = less, 2 = equal, 3 = greater
    url="$GH_REPO/releases/download/v${version}/${TOOL_NAME}_${version}_${os}_${arch}.tar.gz"
  else
    url="$GL_REPO/-/releases/v${version}/downloads/${TOOL_NAME}_${version}_${os}_${arch}.tar.gz"
  fi

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    # TODO: Asert glab executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}

get_os() {
  local version="$1"
  local os=$(uname)
  local compare_result

  compare_versions "$version" "$ARCHIVE_CHANGE_VERSION" || compare_result=$?
  if [ $compare_result -gt 1 ]; then
    case $os in
    Darwin) echo darwin ;;
    Linux) echo linux ;;
    Windows) echo windows ;;
    *) echo $os ;;
    esac
  else
    case $os in
    Darwin) echo macOS ;;
    *) echo $os ;;
    esac
  fi
}

get_arch() {
  local version="$1"
  local arch=$(uname -m)
  local compare_result

  compare_versions "$version" "$ARCHIVE_CHANGE_VERSION" || compare_result=$?
  if [ $compare_result -gt 1 ]; then
    case $arch in
    *86) echo 386 ;;
    aarch64) echo arm64 ;;
    x86_64) echo amd64 ;;
    *) echo $arch ;;
    esac
  else
    case $arch in
    *86) echo i386 ;;
    aarch64) echo arm64 ;;
    *) echo $arch ;;
    esac
  fi
}
