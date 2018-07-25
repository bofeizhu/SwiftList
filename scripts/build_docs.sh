#!/bin/bash

if ! which jazzy >/dev/null; then
  echo "Jazzy not detected: You can download it from https://github.com/realm/jazzy"
  exit
fi


jazzy \
	--clean \
	--author 'zhubofei' \
  --author_url 'https://twitter.com/zhubofei' \
  --github_url 'https://github.com/zhubofei/ListKit' \
  --module-version 0.1.0 \
  --readme README.md \
  --xcodebuild-arguments -workspace,'ListKit.xcworkspace',-scheme,ListKit \
  --module 'ListKit' \
  --output docs/ \
  --theme fullwidth
