#!/bin/bash
# Installation script for firefly_cli

set -o errexit   # abort on nonzero exit code
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# Generate archive suffix based on the OS name and arch.
os=$(uname)
arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
if [ "$os" = "Linux" ]; then
  if [ "$arch" == "x86_64" ]; then
    suffix="-x86_64-unknown-linux-musl.tar.gz"
  elif [ "$arch" == "i386" ] || [ "$arch" == "i686" ]; then
    suffix="-i686-unknown-linux-musl.tar.gz"
  elif [[ "$arch" =~ ^arm ]]; then
    suffix="-arm-unknown-linux-musleabihf.tar.gz"
  else
    echo "Unsupported Linux architecture: $arch"
    exit 1
  fi
elif [ "$os" = "Darwin" ]; then
  if [ "$arch" == "aarch64" ]; then
    suffix="-aarch64-apple-darwin.tar.gz"
  elif [[ "$arch" =~ ^arm ]]; then
    suffix="-aarch64-apple-darwin.tar.gz"
  else
    echo "Unsupported Apple architecture: $arch"
    exit 1
  fi
else
  # TODO(@orsinium): Windows with bash terminal.
  # -i686-pc-windows-msvc.zip
  # -x86_64-pc-windows-gnu.zip
  # -x86_64-pc-windows-msvc.zip
  echo "Unsupported OS"
  exit 1
fi


# Get the latest release version.
echo "Fetching latest release number..."
url="https://github.com/firefly-zero/firefly-cli/releases/latest"
if which curl; then
  resp="$(curl -I ${url})"
else
  resp="$(wget -qSO /dev/null ${url} 2>&1)"
fi
version="$(echo $resp | grep -iPo '[Ll]ocation: \S*')"
version="$(echo $version | grep -oE '[0-9]+.[0-9]+.[0-9]+')"

# Download archive
echo "Downloading latest release..."
archive_name="firefly_cli-v${version}${suffix}"
echo "downloading ${archive_name}..."
url="https://github.com/firefly-zero/firefly-cli/releases/download/${version}/${archive_name}"
tmp_dir="$(mktemp -d)"
archive_path="${tmp_dir}/${archive_name}"
if which curl; then
  curl -L "${url}" -o "${archive_path}"
else
  wget -qO "${archive_path}" "${url}"
fi

# Extract archive
echo "Extracting archive..."
tar -xzf "${archive_path}" -C "${tmp_dir}"

# Execute post-installation script and let it do the rest.
matches=(${tmp_dir}/*/firefly_cli)
"${matches[0]}" postinstall

# Verify installation
bash -c "ff --version"
echo "🎉 ff is installed and works!"
