#!/usr/bin/env nextflow

git_status="${workflow.projectDir}/check_clean.sh".execute().text

if(git_status=~"dirty"){
  throw new Exception("The script directory is dirty. Revert or commit before running!")
}

equal="${workflow.projectDir}/check_equal.sh".execute().text

if(equal=~"inequal"){
  throw new Exception("main.nf is out-of-sync with individual script files.")
}

branch="${workflow.projectDir}/get_branch.sh".execute().text

println(branch)
println("^Branch name^")

if(branch=="master"){
  branch_str=""
}
else{
  branch_str=branch+"-"
}

Channel
  .fromPath( "$params.inputDir/*.txt" )
  .map{ [it.baseName, it] }
  .set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

