#!/bin/sh

set -e

git config --global user.email "romain.lesur@gmail.com"
git config --global user.name "Romain Lesur"
git clone -b gh-pages https://${GITHUB_PAT}@github.com/${TRAVIS_REPO_SLUG}.git output

rm -rf ./output/*

cp -r ./_book ./output

cd output
git add --all -f ./*
git commit --allow-empty -m"Update site - build by travis-ci (#${TRAVIS_REPO_SLUG})"
git push origin gh-pages
