#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq unzip
# shellcheck shell=bash
set -eu -o pipefail

# Directory that the script is executing within.
root="$(realpath "$(dirname "$0")")"
tmp_file="${root}/sources.tmp.json"

# Helper to just fail with a message and non-zero exit code.
function fail() {
  echo "$1" >&2
  exit 1
}

# Helper to clean up after ourselves if we're killed by SIGINT.
function clean_up() {
  tmp_dir="${TMPDIR:-/tmp}"
  echo "Script killed, cleaning up tmpdirs: ${tmp_dir}/vscode_exts_*" >&2
  rm -Rf "${tmp_dir}/vscode_exts_*"
  rm "${tmp_file}"
}

function get_vsixpkg() {
  publisher="${1}"
  extension="${2}"
  name="${1}.${2}"

  # Create a temporary directory for the extension download.
  tmp_dir=$(mktemp -d -t vscode_exts_XXXXXXXX)

  url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${extension}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

  # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
  curl \
    --silent \
    --show-error \
    --retry 3 \
    --fail \
    -X GET \
    -o "${tmp_dir}/${name}.zip" \
    "${url}"

  # Unpack the file we need to stdout then pull out the version.
  version=$(jq -r '.version' <(unzip -qc "${tmp_dir}/${name}.zip" "extension/package.json"))

  # Calculate the hash.
  hash=$(nix hash file --base32 --sri --type sha256 "${tmp_dir}/${name}.zip")

  # Clean up.
  #
  # I don't like 'rm -Rf' lurking in my scripts but this seems appropriate.
  rm -Rf "${tmp_dir}"

  jq --arg name "${extension}" \
     --arg publisher "${publisher}" \
     --arg version "${version}" \
     --arg sha256 "${hash}" \
     -n '$ARGS.named' >> $tmp_file
}

# Try to be a good citizen and clean up after ourselves if we're killed.
trap clean_up SIGINT

sources=$(jq -r '.[] | .publisher + "." + .name' $root/sources.json | uniq)
for source in $sources; do
  publisher=$(echo "${source}" | cut -d "." -f 1)
  extension=$(echo "${source}" | cut -d "." -f 2)

  get_vsixpkg "$publisher" "$extension"
done

jq -s '.' $tmp_file > "$root/sources.json"
rm $tmp_file
