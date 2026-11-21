#!/usr/bin/env bash
file_count=$(find . -type f | wc -l)
echo "Total files: ${file_count}"
