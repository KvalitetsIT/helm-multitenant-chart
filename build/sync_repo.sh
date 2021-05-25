#!/bin/sh
mkdir -p /helm-repo/$chartName/
mv $workspace/$chartName-* $workspace/helm-repo/$chartName/
helm repo index . --url https://raw.githubusercontent.com/KvalitetsIT/helm-repo/master/
