#!/bin/bash
start_time=$SECONDS
git add .
git commit -m "commit $(date)"
git push -u origin main
elapsed=$(( SECONDS - start_time ))
echo "Finish! $elapsed seconds to complete." 


echo "# de-zoomcamp-2023" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:boisalai/de-zoomcamp-2023.git
git push -u origin main