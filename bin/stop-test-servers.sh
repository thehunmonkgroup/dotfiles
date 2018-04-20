#!/usr/bin/env bash

# Convenience script to stop webrtc-test-* servers.

echo "Stopping webrtc-test servers..."

sleep 120 && pb group hard-stop test-10 && pb group status test-10
