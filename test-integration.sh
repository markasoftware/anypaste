#!/usr/bin/env bash
# Execute this file to run integration tests on Anypaste.
# These tests use a custom, offline, set of plugins so that this test is reproducible.
# Therefore, the built-in plugins are not covered by these tests.

# shellcheck disable=2016
# shellcheck disable=2034
# shellcheck disable=1090
# shellcheck disable=1091

# ignore system config file
export XDG_CONFIG_HOME=/this/does/not/exist

shopt -s extglob

function exit {
	last_exit_code="$?"
}

function anypaste {
	source ./anypaste "$@" 2>&1
}

function oneTimeSetUp() {
	if [[ ! -t 0 ]]
	then
		echo 'ERROR: The test must be run with stdin coming from a terminal, not a pipe or file.'
		return 1
	fi
}

function test_no_args() {
	local out exit_code
	out=$(ap_main 2>&1)
	exit_code=$?
	assertEquals 'exits with 102' 102 $exit_code
	assertPatternEquals 'includes help text' '*OPTIONS*' "$out"
	assertPatternEquals 'includes error text' '*ERROR*' "$out"
}

function test_help() {
	local out_h out_help out_stdout exit_code
	out_h=$(ap_main -h 2>&1)
	out_help=$(ap_main --help 2>&1)
	exit_code="$?"
	assertPatternEquals 'includes help text' '*OPTIONS*' "$out_h"
	assertEquals '-h and --help are identical' "$out_h" "$out_help"
	assertEquals 'exit code' 0 "$exit_code"
}

function test_version() {
	local out exit_code
	out=$(ap_main -v 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertPatternEquals 'prints version' 'Anypaste ?.??(.?)?(-*)' "$out"
}

function test_basic_upload() {
	local out exit_code
	out=$(ap_main -p haste ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to Hastebin' '[[ $out == *https://hastebin.skyra.pw/+([a-z])* ]]'
	assertURLIsAnypaste "$out"
}

function test_p_upload() {
	local out exit_code
	out=$(ap_main ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to ixio' '[[ $out == *http://ix.io/+([a-zA-Z0-9])* ]]'
	assertURLIsAnypaste "$out"
}

function test_stdin_upload() {
	local out exit_code
	out=$(ap_main -p haste < ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to Hastebin' '[[ $out == *https://hastebin.skyra.pw/+([a-z])* ]]'
	assertURLIsAnypaste "$out"
}

function test_multi_upload() {
	local out exit_code
	out=$(ap_main -c fixtures/configs/essentials.conf ./anypaste ./LICENSE 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads anypaste' '[[ $out == *"essentials upload anypaste"* ]]'
	assertTrue 'uploads LICENSE' '[[ $out == *"essentials upload LICENSE"* ]]'
}

ap_test=true
source ./anypaste
for i in ./fixtures/plugins/*; do source "$i"; done
source ./extra-assertions.sh
source ./shunit2/shunit2
