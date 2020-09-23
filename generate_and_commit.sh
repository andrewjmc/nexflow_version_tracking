#!/usr/bin/bash
cat header.nf step_*.nf > main.nf
git commit -a -m "$1"
