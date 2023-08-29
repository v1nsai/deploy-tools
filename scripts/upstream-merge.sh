#!/bin/bash

set -e

# $1 = project name
# $2 = branch name

git fetch upstream
git checkout $2
git merge upstream/$2
git filter-repo --path scripts --path projects/$1 --path .gitignore
git push origin $2