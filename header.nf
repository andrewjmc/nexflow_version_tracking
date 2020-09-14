#!/usr/bin/env nextflow

Channel.fromPath( "$params.inputDir/*.txt" ).set{ files_in }

i=0
commits="git log | grep \"^commit\" | cut -d\" \" -f2".execute().text.tokenize("\n").collectEntries{ [it, ++i] }
