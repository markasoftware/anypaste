#!/usr/bin/env bash

set -e
shellcheck ./anypaste
./test.sh
./test-integration.sh
