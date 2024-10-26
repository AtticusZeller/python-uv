#!/usr/bin/env bash

# update CHANGELOG.md
git-cliff -o -v
# bump version and commit with tags
bump-my-version bump patch
# push remote
git push origin main --tags
