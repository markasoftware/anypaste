#!/usr/bin/env bash
# This tests the built-in plugins with actual network activity.
# Don't run it too much, let's not make hosts angry at us! Hell, we don't even run it on Travis!
# Remember what happens when you make the hosts angry in WestWorld?
# shellcheck disable=1091

# TODO: how do we handle testing if there are weird filenames/coming from stdin?

text_fixture=./anypaste
# these images are my own
jpeg_fixture=./fixtures/files/lasers.jpg
png_fixture=./fixtures/files/tux.png
# these audio files are from freesound.org, and were released by their authors under CC 0
wav_fixture=./fixtures/files/boop.wav
mp3_fixture=./fixtures/files/deedoot.mp3
# these are my own screen recordings
# h264
mkv_fixture=./fixtures/files/screen.mkv
webm_fixture=./fixtures/files/screen.webm
gif_fixture=./fixtures/files/screen.gif

function test_hastebin() {
	uploadAndAssert hastebin "$text_fixture"
	assertDirectLinkWorks 'uploads text fixture' "$text_fixture"
	assertLabelPatternEquals 'hastebin normal link' 'Link' 'https://hastebin.com/+([a-z])'
}

function test_ixio() {
	uploadAndAssert ixio "$text_fixture"
	assertDirectLinkWorks 'uploads text fixture' "$text_fixture"
}

function test_vgyme() {
	uploadAndAssert vgyme "$png_fixture"
	# Vgyme's direct links aren't direct -- it reencodes the image (even for png)
	assertLabelPatternEquals 'vgyme direct link' 'Direct' 'https://vgy.me/+([0-9a-zA-Z]).png'
	assertLabelPatternEquals 'vgyme normal link' 'Link' 'https://vgy.me/u/+([0-9a-zA-Z])'
	assertLabelPatternEquals 'vgyme delete link' 'Delete' 'https://vgy.me/delete/+([0-9a-zA-Z])'
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

function test_pomf() {
	uploadAndAssert pomf "$webm_fixture"
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

function test_instaudio() {
	uploadAndAssert instaudio "$wav_fixture"
	assertDirectLinkWorks 'uploads wav fixture' "$wav_fixture"
	assertLabelPatternEquals 'instaud.io normal link' 'Link' 'https://instaud.io/+([0-9a-zA-Z])'
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
}

# TODO: tests for authenticated plugins

# shellcheck disable=2034
ap_test=true
source ./anypaste
source ./extra-assertions.sh
source ./shunit2/shunit2
