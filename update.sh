#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

getLatestVersion(){
  curl -qL "https://pypi.python.org/pypi/sora-sdk/json" | jq -r ".info.version"
}

getUrls(){
  local version=$1
  curl -qL "https://pypi.python.org/pypi/sora-sdk/$version/json" | jq -r '.urls | map({"key":.filename,"value":{"url":.url,"sha256":.digests.sha256}}) | from_entries'
}

getLatestVersion > version.txt
getUrls "$(cat version.txt)" > sources.json
