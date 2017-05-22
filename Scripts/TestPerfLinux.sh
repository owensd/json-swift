#!/bin/bash

docker run --rm \
    --volume "$(pwd):/package" \
    --workdir "/package" \
    swift:3.1 \
    /bin/bash -c \
    "swift package update && swift build -c release --build-path ./.build/linux && ./.build/linux/release/ParserPerfTestHarness -file:./TestCollateral/large-dict.json"