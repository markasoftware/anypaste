#!/usr/bin/env bash
# This tests the built-in plugins with actual network activity.
# Don't run it too much, let's not make hosts angry at us! Hell, we don't even run it on Travis!
# Remember what happens when you make the hosts angry in WestWorld?
# shellcheck disable=1091

# TODO: how do we handle testing if there are weird filenames/coming from stdin?

function test_hastebin() {
	uploadAndAssert hastebin "$text_fixture"
	assertDirectLinkWorks 'uploads text fixture' "$text_fixture"
	assertLabelPatternEquals 'hastebin normal link' 'Link' 'https://hastebin.com/+([a-z])'
}

function test_ixio() {
	uploadAndAssert ixio "$text_fixture"
	assertDirectLinkWorks 'uploads text fixture' "$text_fixture"
}

function test_tinyimg() {
	uploadAndAssert tinyimg "$jpeg_fixture"
	assertDirectLinkWorks 'uploads jpeg fixture' "$jpeg_fixture"
}

function test_imgur() {
	uploadAndAssert imgur "$png_fixture"
	assertLabelPatternEquals 'imgur direct link' 'Direct' 'https://i.imgur.com/+([0-9a-zA-z]).png'
	assertLabelPatternEquals 'imgur normal link' 'Link' 'https://imgur.com/+([0-9a-zA-Z])'
	assertLabelPatternEquals 'imgur edit link' 'Edit' 'https://imgur.com/edit?deletehash=+([0-9a-zA-Z])'
	assertLabelPatternEquals 'imgur delete link' 'Delete' 'https://imgur.com/delete/+([0-9a-zA-Z])'
}

function test_dmca_gripe() {
	uploadAndAssert dmca_gripe "$webm_fixture"
	assertDirectLinkWorks 'uploads webm fixture' "$webm_fixture"
}

function test_transfersh() {
	uploadAndAssert transfersh "$wav_fixture"
	assertDirectLinkWorks 'uploads wav fixture' "$wav_fixture"
}

function test_fileio() {
	# cause why not, and it's smaller than the WAV
	uploadAndAssert fileio "$mp3_fixture"
	assertDirectLinkWorks 'uploads mp3 fixture' "$mp3_fixture"
}

function test_clyp() {
	uploadAndAssert clyp "$mp3_fixture"
	assertDirectLinkWorks 'uploads mp3 fixture' "$mp3_fixture"
	assertLabelPatternEquals 'clyp normal link' 'Link' 'https://clyp.it/+([0-9a-z])'
}

function test_sendvid() {
	uploadAndAssert sendvid "$mkv_fixture"
	assertLabelPatternEquals 'sendvid normal link' 'Link' 'https://sendvid.com/+([0-9a-z])'
	assertLabelPatternEquals 'sendvid delete/edit link' 'Delete/Edit' 'https://sendvid.com/+([0-9a-z])\?secret=+([0-9a-f-])'
}

function test_gfycat() {
	uploadAndAssert gfycat "$gif_fixture"
	# surprise! gfycat re-encodes their "direct links"
	assertLabelPatternEquals 'gfycat direct link' 'Direct' 'https://thumbs.gfycat.com/[A-Z]+([a-z])[A-Z]+([a-z])[A-Z]+([a-z])-size_restricted.gif'
	assertLabelPatternEquals 'gfycat normal link' 'Link' 'https://gfycat.com/[A-Z]+([a-z])[A-Z]+([a-z])[A-Z]+([a-z])'

	uploadAndAssert gfycat "$mkv_fixture"
	assertLabelPatternEquals 'gfycat direct link (mkv)' 'Direct' 'https://thumbs.gfycat.com/[A-Z]+([a-z])[A-Z]+([a-z])[A-Z]+([a-z])-size_restricted.gif'
	assertLabelPatternEquals 'gfycat normal link (mkv)' 'Link' 'https://gfycat.com/[A-Z]+([a-z])[A-Z]+([a-z])[A-Z]+([a-z])'
}

function test_filemail() {
	uploadAndAssert filemail "$wav_fixture"
	assertDirectLinkWorks 'uploads wav fixture' "$wav_fixture"
}

# TODO: tests for authenticated plugins

# shellcheck disable=2034
ap_test=true
source ./anypaste
source ./extra-assertions.sh
source ./fixture-paths.sh
source ./shunit2/shunit2
