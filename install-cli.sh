#!/bin/bash
# Installation script for firefly_cli
set -e
set -o pipefail

function get_latest_version() {
  # TODO(@orsinium): curl might be not installed, fallback to wget.
  local resp="$(curl https://api.github.com/repos/firefly-zero/firefly-cli/releases/latest)"
  local tag="$(echo $resp | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
  echo "${tag}"
  return 0
}

function get_archive_suffix() {
  local os=$(uname)
  local arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
  if [ "$os" = "Linux" ]; then
    if [ "$arch" == "x86_64" ]; then
      echo "-x86_64-unknown-linux-musl.tar.gz"
      return 0
    elif [ "$arch" == "i386" ] || [ "$arch" == "i686" ]; then
      echo "-i686-unknown-linux-musl.tar.gz"
      return 0
    elif [[ "$arch" =~ ^arm ]]; then
      echo "-arm-unknown-linux-musleabihf.tar.gz"
      return 0
    else
      echo "Unsupported Linux architecture: $arch"
      return 1
    fi
  elif [ "$os" = "Darwin" ]; then
    if [ "$arch" == "aarch64" ]; then
      echo "-aarch64-apple-darwin.tar.gz"
      return 0
    else
      echo "Unsupported Apple architecture: $arch"
      return 1
    fi
  else
    # TODO(@orsinium): Windows with bash terminal.
    # -i686-pc-windows-msvc.zip
    # -x86_64-pc-windows-gnu.zip
    # -x86_64-pc-windows-msvc.zip
    echo "Unsupported OS"
    return 1
  fi
}

function download_archive() {
  local version="$(get_latest_version)"
  local suffix="$(get_archive_suffix)"
  local archive_name="firefly_cli-v${version}${suffix}"
  local url="https://github.com/firefly-zero/firefly-cli/releases/download/${version}/${archive_name}"
  local tmp_dir="$(mktemp -d)"
  local file_path="${tmp_dir}/${archive_name}"
  curl -L "${url}" -o "${file_path}"
  echo "${file_path}"
  return 0
}

function find_writable_path() {
  return "."
}

function install_from_github() {
  local archive_path="$(download_archive)"
  local tmp_dir="$(dirname ${archive_path})"
  tar -xzf "${archive_path}" -C "${tmp_dir}"
  local out_dir="$(find_writable_path)"
  mv "${tmp_dir}/*/firefly_cli" "${out_dir}/"
}

function install() {
  # if which cargo > /dev/null; then
  #   cargo install firefly-cli
  #   return
  # fi
  install_from_github
}

install
