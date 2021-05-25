#!/bin/bash

echo "hej"

mkdir -p helm
cd helm
git config --global user.name "Github Actions"
git config --global user.email "development@kvalitetsit.dk"
git clone https://github.com/KvalitetsIT/helm-repo
cd helm-repo
ls -a
cp ../../multitenant-*.tgz multitenant
cp ../../index.yaml .
git add -A
git commit -m "Adding new multitenant chart"
git push https://$1@github.com/KvalitetsIT/helm-repo
