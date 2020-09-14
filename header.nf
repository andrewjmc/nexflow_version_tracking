#!/usr/bin/env nextflow

Channel.fromPath( "$params.inputDir/*.txt" ).set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

