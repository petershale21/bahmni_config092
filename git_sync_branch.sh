#!/usr/bin/env bash

# checks if something happened on the remote repo

git fetch

# now see if there's anything that happened

git diff HEAD remotes/origin/master

# Now get ONLY files that were edited. This will
# help in preserving bandwith

get fetch origin
