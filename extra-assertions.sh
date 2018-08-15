#!/usr/bin/env bash

shopt -s extglob

# @param $1 error message
# @param $2 globby pattern
# @param $3 text
function assertPatternEquals {
	# failNotEquals is defined in shunit
	# shellcheck disable=2053
	[[ $3 == $2 ]] || failNotEquals "$1" "$2" "$3"
}

# @param $1 error message
# @param $2 text which the file at the URL should equal
# @param $3 URL
function assertURLEquals {
	local curl_output
	curl_output=$(curl -s "$3")
	assertEquals "$1" "$2" "$curl_output"
}

# @param $1 name of a plugin
function assertGetInfoWorks {
	local out exit_code
	out=$("$1" get_info)
	exit_code=$?
	assertEquals "$1 get_info exit code" 0 "$?"
	assertPatternEquals "$1 get_info has [name]" '*[name]*' "$out"
}

# internal helper
# @param $1 label of the link to retrieve
# @return stdout the link in its full glory
function get_output_link {
	local grep_output
	# TODO: BASH_REMATCH instead
	grep_output=$(grep "^$1: " <<< "$ap_t_upload_stdout")
	echo "${grep_output#*: }"
	exit
}

# @param $1 error message
# @param $2 file path
function assertDirectLinkWorks {
	local file_content direct_link
	direct_link=$(get_output_link 'Direct')
	assertNotNull 'direct link was outputted' "$direct_link"
	file_content=$(<"$2")
	assertURLEquals "$1" "$file_content" "$direct_link"
}

# @param $1 name of a plugin
# @param $2 file to upload
# @return $ap_t_upload_stdout stdout of the upload for further assertions
function uploadAndAssert {
	local out exit_code file_content out_link

	assertGetInfoWorks "$1"

	ap_rel_to_abs "$2"
	ap_path=$ap_rel_to_abs_return
	ap_collect_file_metadata "$2"
	"$1" check_eligibility
	exit_code=$?
	assertEquals "$1 check_eligibility exits ok" 0 "$exit_code"

	ap_t_upload_stdout=$("$1" upload)
}

# @param $1 error message
# @param $2 the label we are looking at
# @param $3 the pattern to match
function assertLabelPatternEquals {
	local out_link
	out_link=$(get_output_link "$2" "$ap_t_upload_stdout")
	assertPatternEquals "$1" "$3" "$out_link"
}
