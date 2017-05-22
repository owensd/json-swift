#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	DIR="$(pwd)"
	cd ..
	export SWIFT_VERSION=swift-3.1.1-RELEASE
    wget https://swift.org/builds/swift-3.1.1-release/ubuntu1404/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu14.04.tar.gz
	tar xzf $SWIFT_VERSION-ubuntu14.04.tar.gz
	export PATH="${PWD}/${SWIFT_VERSION}-ubuntu14.04/usr/bin:${PATH}"
	cd "$DIR"
else
	export SWIFT_VERSION=swift-3.1.1-RELEASE
    curl -O https://swift.org/builds/swift-3.1.1-release/xcode/${SWIFT_VERSION}/${SWIFT_VERSION}-osx.pkg
	sudo installer -pkg ${SWIFT_VERSION}-osx.pkg -target /
	export TOOLCHAINS=swift
fi
