#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.beautifulsoup4 python3Packages.requests

import json
from concurrent.futures import ThreadPoolExecutor
import os
import subprocess
from tempfile import NamedTemporaryFile

from bs4 import BeautifulSoup
import requests

ROOT_PATH = os.path.dirname(os.path.realpath(__file__))

# Mapping between VS Code platforms (keys) & Nix platforms (values).
PLATFORMS = {
    "darwin-x64": "x86_64-darwin",
    "darwin-arm64": "aarch64-darwin",
    "linux-x64": "x86_64-linux",
    "linux-arm64": "aarch64-linux",
}


def get_extension_sha(url):
    """Get the base32 SRI hash for the VS Code extension at some url."""
    resp = requests.get(url)
    sha = None
    with NamedTemporaryFile() as extension:
        extension.write(resp.content)
        sha = calculate_nix_sha(extension.name)
    return sha


def calculate_nix_sha(fpath):
    """Calculate the base32 SRI hash for a given package."""
    sha = subprocess.check_output(
        ["nix", "hash", "file", "--base32", "--sri", "--type", "sha256", fpath]
    )
    return sha.decode().strip()


def get_multiarch_ext_url(version_blob):
    """Get the extension download URL for a given platform."""
    platform = version_blob["targetPlatform"]
    url = get_ext_url(version_blob)
    sha = get_extension_sha(url)
    return {PLATFORMS[platform]: {"url": url, "sha256": sha}}


def get_multiarch_ext_urls(target_version, version_blobs):
    """Get the extension download URLs for any matching platforms."""
    futures = []
    with ThreadPoolExecutor(max_workers=4) as e:
        for blob in version_blobs:
            if (blob["targetPlatform"] in PLATFORMS) and (
                blob["version"] == target_version
            ):
                future = e.submit(get_multiarch_ext_url, blob)
                futures.append(future)

    results = {}
    for future in futures:
        results.update(future.result())
    return results


def get_ext_url(version_blob):
    """Get the extension download URL for a VS Code extension."""
    # XXX: Presumably there's a more idiomatic way to do this...
    return next(
        (
            file["source"]
            for file in version_blob["files"]
            if file["assetType"] == "Microsoft.VisualStudio.Services.VSIXPackage"
        )
    )


def get_ext_blobs(publisher, ext_name):
    """Get the metadata associated with some VS Code extension."""
    name = f"{publisher}.{ext_name}"
    params = {"itemName": name, "ssr": "false"}
    url = "https://marketplace.visualstudio.com/items#version-history"

    page = requests.get(url, params=params)
    soup = BeautifulSoup(page.content, "html.parser")

    ext_txt = soup.find("script", {"class": "vss-extension"}).get_text()
    ext_json = json.loads(ext_txt)
    return ext_json["versions"]


def get_ext_info(source):
    """Get the download information for a VS Code extension."""
    publisher = source["publisher"]
    ext_name = source["name"]
    version_blobs = get_ext_blobs(publisher, ext_name)
    latest = version_blobs[0]
    version = latest["version"]

    # If the version hasn't changed, don't do any more work.
    current_version = source.get('version')
    if (current_version is not None) and (version == current_version):
        return source

    is_multiarch = "targetPlatform" in latest

    src = {"name": f"{publisher}-{ext_name}-{version}.zip"}
    if is_multiarch:
        platforms = get_multiarch_ext_urls(version, version_blobs)
        src["platforms"] = platforms
    else:
        url = get_ext_url(latest)
        src["url"] = url
        src["sha256"] = get_extension_sha(url)
    return {"publisher": publisher, "name": ext_name, "version": version, "src": src}


sources = []
with open(f"{ROOT_PATH}/sources.json", "r", encoding="utf-8") as f:
    sources = json.load(f)

futures = None
with ThreadPoolExecutor(max_workers=4) as e:
    futures = e.map(get_ext_info, sources)

updated_sources = [future for future in futures]

with open(f"{ROOT_PATH}/sources.tmp.json", "w", encoding="utf-8") as f:
    json.dump(updated_sources, f, ensure_ascii=False, indent=4)

os.replace(f"{ROOT_PATH}/sources.tmp.json",f"{ROOT_PATH}/sources.json")
