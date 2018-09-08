#!/usr/bin/env bash
# Execute this file to run integration tests on Anypaste.
# These tests use a custom, offline, set of plugins so that this test is reproducible.
# Therefore, the built-in plugins are not covered by these tests.

# shellcheck disable=2016
# shellcheck disable=2034

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
	exit_code="$?"
	assertEquals 'exit code' 102 "$exit_code"
	assertTrue 'prints error message' '[[ $out == *ERROR* ]]'
	assertTrue 'prints help text' '[[ $out == *OPTIONS* ]]'
}

function test_help() {
	local out_h out_help out_stdout exit_code
	out_h=$(ap_main -h 2>&1)
	out_help=$(ap_main --help 2>&1)
	exit_code="$?"
	assertTrue 'prints help text' '[[ $out_h == *OPTIONS* ]]'
	assertEquals '-h and --help are identical' "$out_h" "$out_help"
	assertEquals 'exit code' 0 "$exit_code"
}

function test_version() {
	local out exit_code
	out=$(ap_main -v 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'prints version' '[[ $out == Anypaste" "?.??(.?) ]]'
}

function test_basic_upload() {
	local out exit_code
	out=$(ap_main ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to Hastebin' '[[ $out == *https://hastebin.com/+([a-z])* ]]'
	is_url_anypaste "$out"
}

function test_p_upload() {
	local out exit_code
	out=$(ap_main -p ixio ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to ixio' '[[ $out == *http://ix.io/+([a-zA-Z0-9])* ]]'
	is_url_anypaste "$out"
}

function test_stdin_upload() {
	local out exit_code
	out=$(ap_main < ./anypaste 2>&1)
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads to Hastebin' '[[ $out == *https://hastebin.com/+([a-z])* ]]'
	is_url_anypaste "$out"
}

function test_multi_upload() {
	local out exit_code
	out=$(ap_main -c fixtures/configs/essentials.conf ./anypaste ./LICENSE)
	echo "$out"
	exit_code="$?"
	assertEquals 'exit code' 0 "$exit_code"
	assertTrue 'uploads anypaste' '[[ $out == *"essentials upload anypaste" ]]'
	assertTrue 'uploads LICENSE' '[[ $out == *"essentials upload LICENSE" ]]'
}

ap_test=true
source ./anypaste
for i in ./fixtures/plugins/*; do source "$i"; done
source ./shunit2/shunit2
