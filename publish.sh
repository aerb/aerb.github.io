#!/bin/bash

set -e

rm -Rf public
rm -Rf publish-branch/*
hugo
cp -Rv public/* publish-branch
cd publish-branch
git add .
git commit -m "Publishing updates"
git push