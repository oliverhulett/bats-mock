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

function _stub_env()
{
	stub "$@"
	rv=$?
	command env | command grep -E '_STUB_(END|PLAN|RUN)=' | command sort
	return $rv
}
@test "stub sets up environment" {
	for t in "program.name _PROGRAM_NAME" \
			 "1name _1NAME" \
			 "funny-characters _FUNNY_CHARACTERS" \
			 "repeated.-characters _REPEATED_CHARACTERS"; do
		set -- $t
		program_name="$1"
		expected_prefix="$2"
		run _stub_env "${program_name}"
		assert_success
		assert_equal "${expected_prefix}_STUB_END=" "${lines[0]}"
		assert_equal "${expected_prefix}_STUB_PLAN=${WD}/${program_name}-stub-plan" "${lines[1]}"
		assert_equal "${expected_prefix}_STUB_RUN=${WD}/${program_name}-stub-run" "${lines[2]}"
	done
}

@test "stub links to binstub" {
	program_name="exe"
	run stub "${program_name}"
	assert_success
	assert_output ""
	assert test -d "${WD}/bin"
	assert test -L "${WD}/bin/${program_name}"
	assert_equal "$(cd "${BATS_TEST_DIRNAME}/../src" && pwd -P)/binstub" "$(readlink -f "${WD}/bin/${program_name}")"
}

@test "stub writes plan file" {
	program_name="exe"
	run stub "${program_name}" "arg1 arg2" "args : run this"
	assert_success
	assert_output ""
	assert test -f "${WD}/${program_name}-stub-plan"
	run cat "${WD}/${program_name}-stub-plan"
	assert_equal "arg1 arg2" "${lines[0]}"
	assert_equal "args : run this" "${lines[1]}"
}

@test "unstub removes link to binstub and plan file" {
	mkdir --parents "${WD}/bin"
	ln -s "${BATS_TEST_DIRNAME}/../src/binstub" "${WD}/bin/program"
	touch "${WD}/program-stub-plan" "${WD}/program-stub-run"
	export _PROGRAM_STUB_PLAN="${WD}/program-stub-plan"
	export _PROGRAM_STUB_RUN="${WD}/program-stub-run"
	export _PROGRAM_STUB_INDEX=1
	run unstub "program"
	assert_success
	assert_output ""
	assert [ ! -f "${BATS_MOCK_BINDIR}/program" ]
	assert [ ! -f "${BATS_MOCK_TMPDIR}/program-stub-plan" ]
	assert [ ! -f "${BATS_MOCK_TMPDIR}/program-stub-run" ]
}
