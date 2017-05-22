#!/bin/bash

docker run --rm \
    --volume "$(pwd):/package" \
    --workdir "/package" \
    swift:3.1 \
    /bin/bash -c \
    "swift package update && swift test --build-path ./.build/linux"