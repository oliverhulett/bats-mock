#!/usr/bin/env bats

load "bats-support/load"
load "bats-assert/all"

function setup()
{
	export WD="$(mktemp -d --tmpdir="${BATS_TMPDIR}")"
	export BATS_TMPDIR="${WD}"
	source "${BATS_TEST_DIRNAME}/../src/stub.bash"
}

function teardown()
{
	rm -rf "${WD}"
}

@test "stub in setup" {
	TSTFILE="$(mktemp --tmpdir="${WD}" --suffix=".bats")"
	cat >"${TSTFILE}" <<-EOF
	source "${BATS_TEST_DIRNAME}/../src/stub.bash"
	function setup()
	{
		stub echo "this : echo that"
	}
	@test "test no echo" {
		true
	}
	@test "test echo something else" {
		run echo this
		assert_equal "this" "\${line[0]}"
	}
	function teardown()
	{
		unstub echo
	}
	EOF
	run bats "${TSTFILE}"
	assert_success
}
