#!/usr/bin/env bash

hugo --minify
cd public
git add .
git commit -m "Site rebuild $(date)"
git push -u origin HEAD
