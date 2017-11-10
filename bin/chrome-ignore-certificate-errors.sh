#!/usr/bin/env bash

# Quick opening of Google Chrome with SSL certificate checks disabled.

open -a "Google Chrome" --args --user-data-dir=/Users/hunmonk/chrome-profiles/stable --ignore-certificate-errors

