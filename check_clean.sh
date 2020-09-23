#!/usr/bin/bash
git status --porcelain | grep -E '^( M)|(MM)|(\?\?)'>/dev/null && echo -n 'dirty' || echo -n 'clean'
