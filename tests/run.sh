#!/bin/bash
set -e

HERE="$(dirname "${BASH_SOURCE[0]}")"

if [ ! -d "${HERE}/bats" ] || [ ! -d "${HERE}/bats-support" ] || [ ! -d "${HERE}/bats-assert" ]; then
	${HERE}/install.sh
fi

export PATH="$(cd "${HERE}/bats/libexec" && pwd -P):$PATH"
${HERE}/bats/bin/bats -t "${HERE}"
