#!/bin/bash
# run it from the terminal with: bash copy_to_entxt.sh

# Create entxt directory
mkdir -p entxt

# Copy directories while excluding .csv and __pycache__
# Using rsync for robustness: -a (archive), -v (verbose), --exclude pattern
# Copy contents of source folders into respective subfolders in entxt
rsync -av --exclude '*.csv' --exclude '__pycache__' matlab/ entxt/matlab/
rsync -av --exclude '*.csv' --exclude '__pycache__' python/ entxt/python/
rsync -av --exclude '*.csv' --exclude '__pycache__' R/ entxt/R/
rsync -av --exclude '*.csv' --exclude '__pycache__' stata/ entxt/stata/

# Copy readme files from root
cp readme.md entxt/
cp readme.pdf entxt/

# Recursively rename files in entxt: change extension to .txt if not .pdf
# We use 'find' to locate files, then execute a shell command to rename them.
# The condition ! -name "*.pdf" ensures PDFs are skipped.
find entxt -type f ! -name "*.pdf" -exec sh -c 'mv "$1" "${1%.*}.txt"' _ {} \;

echo "Operation completed. Files copied to 'entxt' and renamed to .txt (except .pdf)."

