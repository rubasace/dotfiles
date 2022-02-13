#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_CONFIG_DIR="${SCRIPT_DIR}/config"

find "${REPO_CONFIG_DIR}" -mindepth 1 -maxdepth 1 -type f -exec sh -c 'ln -sf {} "${HOME}/$(basename {})"' \;

find "${REPO_CONFIG_DIR}" -mindepth 1 -maxdepth 1 -type d -exec sh -c 'rm -rf "${HOME}/.config/$(basename {})" && ln -sf {} "${HOME}/.config/$(basename {})"' \;