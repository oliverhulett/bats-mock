# shellcheck shell=bash
BATS_MOCK_TMPDIR="${BATS_TMPDIR}"
BATS_MOCK_BINDIR="${BATS_MOCK_TMPDIR}/bin"

PATH="$BATS_MOCK_BINDIR:$PATH"

stub() {
  local program="$1"
  local prefix
  prefix="_$(echo -n "$program" | tr -cs '[:alnum:]' _ | tr '[:lower:]' '[:upper:]')"
  shift
  local tmpdir="${BATS_MOCK_TMPDIR}/${BATS_TEST_NAME}"
  mkdir --parents "${tmpdir}"

  # shellcheck disable=SC2140
  export "${prefix}_STUB_PLAN"="${tmpdir}/${program}-stub-plan"
  # shellcheck disable=SC2140
  export "${prefix}_STUB_RUN"="${tmpdir}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${BATS_MOCK_BINDIR}"
  ln -sf "${BASH_SOURCE[0]%stub.bash}binstub" "${BATS_MOCK_BINDIR}/${program}"

  touch "${tmpdir}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${tmpdir}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix
  prefix="_$(echo -n "$program" | tr -cs '[:alnum:]' _ | tr '[:lower:]' '[:upper:]')"
  local path="${BATS_MOCK_BINDIR}/${program}"
  local tmpdir="${BATS_MOCK_TMPDIR}/${BATS_TEST_NAME}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  rm -f "$path"
  rm -f "${tmpdir}/${program}-stub-plan" "${tmpdir}/${program}-stub-run"
  rmdir --parents "${BATS_MOCK_BINDIR}" 2>/dev/null || true
  rmdir --parents "${tmpdir}" 2>/dev/null || true
  if [ $STATUS -ne 0 ]; then
    fail "unstub $program failed with status $STATUS"
  fi
  return "$STATUS"
}
