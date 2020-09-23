#!/usr/bin/bash
git log | grep "^commit" | cut -d" " -f2
