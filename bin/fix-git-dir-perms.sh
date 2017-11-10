#!/usr/bin/env bash

find . -type f | xargs chmod 644
chmod 755 hooks/* && chmod 744 config
