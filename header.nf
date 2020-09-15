#!/usr/bin/env nextflow

git_status="git --git-dir ${workflow.projectDir} status --porcelain | grep -E '^( M)|(MM)|(\\?\\?)'>/dev/null && echo 'dirty' || echo 'clean'".execute().text

if(git_status=~"dirty"){
  throw new Exception("The script directory is dirty. Revert or commit before running.")
}



Channel
  .fromPath( "$params.inputDir/*.txt" )
  .map{ [it.baseName, it] }
  .set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

