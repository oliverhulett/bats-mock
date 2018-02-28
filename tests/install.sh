#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" || ( echo "Failed to cd into tests directory" && exit 1 )

for repo in "https://github.com/sstephenson/bats.git" \
			"https://github.com/ztombol/bats-support.git" \
			"https://github.com/jasonkarns/bats-assert.git"; do
	[ -d "$(basename -- "${repo}" .git)" ] || git clone --depth=1 "${repo}"
done
