#!/usr/bin/bash
cat header.nf step_*.nf | cmp main.nf > /dev/null && echo -n "equal" || echo -n "inequal"
