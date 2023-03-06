#!/usr/bin/env bash
# shellcheck disable=1090
# shellcheck disable=1091
# shellcheck disable=2034
# shellcheck disable=2154

test_ap_is_video() {
	local code
	ap_path=$webm_fixture
	ap_collect_file_metadata
	ap_is_video
	code=$?
	assertEquals 'webm is video' 0 "$code"

	ap_path=$mkv_fixture
	ap_collect_file_metadata
	ap_is_video
	code=$?
	assertEquals 'mkv is video' 0 "$code"

	ap_path=$gif_fixture
	ap_collect_file_metadata
	ap_is_video
	code=$?
	assertEquals 'gif is not video' 1 "$code"

	ap_path=$wav_fixture
	ap_collect_file_metadata
	ap_is_video
	code=$?
	assertEquals 'wav is not video' 1 "$code"
}

test_ap_is_gif() {
	local code
	ap_path=$gif_fixture
	ap_collect_file_metadata
	ap_is_gif
	code=$?
	assertEquals 'gif is gif' 0 "$code"

	ap_path=$mkv_fixture
	ap_collect_file_metadata
	ap_is_gif
	code=$?
	assertEquals 'mkv is not gif' 1 "$code"

	ap_path=$png_fixture
	ap_collect_file_metadata
	ap_is_gif
	code=$?
	assertEquals 'png is not gif' 1 "$code"
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
	ap_local_plugins=('essentials')
	ap_filter_local_plugins >/dev/null
	assertEquals 'single compatible plugin' 'essentials' "${ap_local_plugins[*]}"

	ap_local_plugins=('essentials' 'taggy_1')
	ap_filter_local_plugins >/dev/null
	assertEquals 'two compatible plugins' 'essentials taggy_1' "${ap_local_plugins[*]}"

	ap_local_plugins=('incompatible')
	ap_filter_local_plugins >/dev/null
	assertNull 'one incompatible plugin' "${ap_local_plugins[*]}"

	ap_local_plugins=('essentials' 'incompatible' 'taggy_1')
	ap_filter_local_plugins >/dev/null
	assertEquals 'incompatible surrounded by two compatible plugins' 'essentials taggy_1' "${ap_local_plugins[*]}"

	ap_local_plugins=('config_foo')
	foo=
	bar=
	titties=
	ap_filter_local_plugins >/dev/null 2>&1
	assertNull 'incompatible because of required config' "${ap_local_plugins[*]}"

	ap_local_plugins=('config_foo')
	foo=bar
	bar=
	titties=
	ap_filter_local_plugins >/dev/null
	assertEquals 'has required config' 'config_foo' "${ap_local_plugins[*]}"

	ap_local_plugins=('config_foo')
	foo=bar
	bar=foo
	titties=big
	ap_filter_local_plugins >/dev/null
	assertEquals 'has required config and optional' 'config_foo' "${ap_local_plugins[*]}"
}

test_ap_summary() {
	local out
	ap_ok_uls=('a' 'b')
	ap_fail_uls=()
	out=$(ap_summary 2>&1)
	assertEquals 'two sucessful uploads' "Sucessfully uploaded: 'a' 'b'" "$out"

	ap_ok_uls=('a')
	ap_fail_uls=('b')
	out=$(ap_summary 2>&1)
	assertEquals 'one ok, one fail' "Sucessfully uploaded: 'a'
Failed to upload: 'b'" "$out"

	ap_ok_uls=()
	ap_fail_uls=('a' 'b')
	out=$(ap_summary 2>&1)
	assertEquals 'two fails only' "Sucessfully uploaded: None
Failed to upload: 'a' 'b'" "$out"
}

test_json_parse() {
	local out
	out=$(json_parse '{"hello":"world"}' 'hello')
	assertEquals 'basic json' 'world' "$out"

	out=$(json_parse '{"hello":42}' 'hello')
	assertEquals 'numerical (no quotes)' '42' "$out"

	out=$(json_parse '{"success":true}' 'success')
	assertEquals 'true/false (no quotes)' 'true' "$out"

	out=$(json_parse '{"hello":"world"}' 'hello')
	assertEquals 'basic json' 'world' "$out"

	out=$(json_parse '{  "hello"  : "world"   }' 'hello')
	assertEquals 'extra cosmetic spaces' 'world' "$out"

	out=$(json_parse '{  "h e l  l o"  : "wor  ld"   }' 'h e l  l o')
	assertEquals 'extra spaces in keys/values' 'wor  ld' "$out"

	out=$(json_parse '{"hello":"world","foo":"bar","cat":"eat dog"}' 'foo')
	assertEquals 'simple multiprop' 'bar' "$out"

	out=$(json_parse '{  "hello" : "world"  , "f oo" :"ba r"  , "cat": "eat dog"  }' 'f oo')
	assertEquals 'multiprop with some extra spaces' 'ba r' "$out"

	out=$(json_parse '{"hello":"world","world":"hello"}' 'world')
	assertEquals 'key name appears earlier' 'hello' "$out"

	out=$(json_parse '{
             "hello": "world",
             "bye": "sonny"
          }' 'bye')
	assertEquals 'multi line' 'sonny' "$out"

	out=$(json_parse '{"hello":"wor\/ld"}' 'hello')
	assertEquals 'escaped slash' 'wor/ld' "$out"
}

test_url_encode() {
	ap_url_encode 'yessir'
	assertEquals "$ap_url_encode_return" yessir
	ap_url_encode 'yes sir'
	assertEquals "$ap_url_encode_return" 'yes%20sir'
	ap_url_encode 'yes.sir'
	assertEquals "$ap_url_encode_return" yes.sir
}

test_upload_loop() {
	ap_i=false
	ap_f=false
	ap_list=false

	# no plugins at all
	ap_user_path=a
	ap_local_plugins=()
	out=$(upload_loop 2>&1)
	exit_code=$?
	assertEquals 'failed' '1' "$exit_code"
	assertPatternEquals 'correct error message' '*No compatible plugins found*' "$out"

	# one sucessful plugin
	ap_user_path=a
	ap_local_plugins=('essentials')
	out=$(upload_loop 2>&1)
	exit_code=$?
	assertEquals 'suceeded' '0' "$exit_code"
	assertPatternEquals 'uploaded the essentials' '*essentials upload*' "$out"

	ap_user_path=a
	ap_local_plugins=('upload_fail')
	out=$(upload_loop 2>&1)
	exit_code=$?
	assertEquals 'failed' '1' "$exit_code"
}

# shellcheck disable=2034
ap_test='true'
source ./anypaste
for i in ./fixtures/plugins/*; do source "$i"; done
source ./extra-assertions.sh
source ./fixture-paths.sh
source ./shunit2/shunit2
