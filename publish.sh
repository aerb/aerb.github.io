#!/bin/bash

set -e

rm -Rf public
rm -Rf publish-branch/*
hugo
cp -Rv public/* publish-branch