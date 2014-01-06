#!/bin/bash

for buildscript in $(grep -v ^# series); do
    # keep individual builds from polluting each other
    bash $buildscript "$@"
    rc=$?
    if [[ 0 -ne $rc ]]; then
        exit 1
    fi
done
