#!/usr/bin/env bash
set -e

cat pom.xml|grep "^    <version>" |sed -n 's/^.*>\([0-9]*\.[0-9]*\.[0-9]*\)<\/version>$/\1/p'