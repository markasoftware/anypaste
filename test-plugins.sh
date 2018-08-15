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

# shellcheck disable=2034
ap_test=true
source ./anypaste
source ./extra-assertions.sh
source ./shunit2/shunit2
