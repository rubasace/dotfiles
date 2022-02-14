#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_CONFIG_DIR="${SCRIPT_DIR}/config"

find "${REPO_CONFIG_DIR}" -mindepth 1 -maxdepth 1 -type f -exec sh -c 'ln -sf {} "${HOME}/$(basename {})"' \;

mkdir -p "${HOME}/.config"

find "${REPO_CONFIG_DIR}" -mindepth 1 -maxdepth 1 -type d -exec sh -c 'lnTargetDir="${HOME}/.config/$(basename {})" && unlink "${lnTargetDir}"; ln -sf {} "${lnTargetDir}"' \;