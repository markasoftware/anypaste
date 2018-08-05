#!/usr/bin/env bash

test_version() {
	local out_v out_version exit_code
	out_v=$(ap_main -v)
	exit_code=$?
	assertTrue 'printed a version' '[[ $out_v == Anypaste" "?.??(.?) ]]'
	assertEquals 'exited sucessfully' 0 $exit_code
	out_version=$(ap_main --version)
	exit_code=$?
	assertEquals '-v and --version are the same' "$out_v" "$out_version"
	assertEquals '--version exits sucessfully' 0 $exit_code
}

test_no_args() {
	local out exit_code
	out=$(ap_main 2>&1)
	exit_code=$?
	assertEquals 'exits with 102' 102 $exit_code
	assertTrue 'includes help text' '[[ $out == *OPTIONS* ]]'
}

test_ap_search_plugins_foo() {
	local ap_search_plugins_arg ap_search_plugins_return
	ap_search_plugins_arg=('foo')
	# $1 will be null
	ap_search_plugins
	assertEquals 'one plugin returned' 1 "${#ap_search_plugins_return[@]}"
	assertEquals 'returns plugin foo' 'foo' "$ap_search_plugins_return"
}

test_ap_search_plugins_foobar() {
	local ap_search_plugins_arg ap_search_plugins_return
	ap_search_plugins_arg=('foo' 'bar' 'car')
	ap_search_plugins 'ar'
	assertEquals 'two plugin returned' 2 "${#ap_search_plugins_return[@]}"
	assertEquals 'returns plugin bar and car' 'bar car' "${ap_search_plugins_return[*]}"
}

test_ap_get_section() {
	local ap_get_section_return code
	ap_get_section 'essentials' 'name'
	code=$?
	assertEquals 'no error for single-line name' 0 $code
	assertEquals 'returns single-line name' "$ap_get_section_return" $'essentials\n' 
	ap_get_section 'essentials' 'description'
	code=$?
	assertEquals 'no error for single-line decription' 0 $code
	assertEquals 'returns single-line description' "$ap_get_section_return" $'essentials\n'

	ap_get_section 'weird_info' 'description'
	code=$?
	assertEquals 'no error for brackets in description' 0 $code
	assertEquals 'returns description with brackets' $'I love brackets: [ ]\n' "$ap_get_section_return"
	ap_get_section 'weird_info' 'tags'
	code=$?
	assertEquals 'no error for empty lines' 0 $code
	assertEquals 'skips empty lines in tags' $'But not just\nBrackets\n' "$ap_get_section_return"

	ap_get_section 'essentials' 'hullabaloo'
	code=$?
	assertEquals 'error when section does not exist' 1 $code
}

test_ap_filter_global_plugins() {
	local ap_global_plugins ap_p ap_t
	ap_global_plugins=('foo' 'bar')
	ap_filter_global_plugins
	assertEquals 'without options, do nothing' 'foo bar' "${ap_global_plugins[*]}"

	ap_p='ar'
	ap_global_plugins=('foo' 'bar')
	ap_filter_global_plugins
	assertEquals 'just -p' 'bar' "${ap_global_plugins[*]}"
	ap_p=

	ap_t='private'
	ap_global_plugins=('essentials' 'taggy_1' 'weird_info')
	ap_filter_global_plugins
	assertEquals 'just -t' 'taggy_1' "${ap_global_plugins[*]}"
	ap_t=

	ap_t='private,permanent'
	ap_global_plugins=('essentials' 'taggy_1' 'taggy_2' 'weird_info')
	ap_filter_global_plugins
	assertEquals 'just -t, multiple tags' 'taggy_2' "${ap_global_plugins[*]}"
	ap_t=

	ap_p='1'
	ap_t='deletable'
	ap_global_plugins=('essentials' 'weird_info' 'taggy_1' 'taggy_2')
	ap_filter_global_plugins
	assertEquals 'both -t and -p' 'taggy_1' "${ap_global_plugins[*]}"
	ap_p=
	ap_t=
}

test_ap_filter_local_plugins() {
	local ap_local_plugins
}

ap_test='true'
source ./anypaste
for i in ./fixtures/plugins/*; do source "$i"; done
source ./shunit2/shunit2
