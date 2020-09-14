#!/usr/bin/env nextflow

Channel.fromPath( "$params.inputDir/*.txt" ).set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

process step_1 {

  storeDir 'results/step_1'

  input:
  file(file_in) from files_in
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]
  file(code) from path("${workflow.projectDir/step_1.nf")

  output:
  file("${file_in.baseName}_processed.${version}.txt") into step_1_output
  file("*.${version}.nf") into step_1_code

  script:
  """
  file_contents=`cat $file_in`
  echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  mv step_1.nf step_1.${version}.nf
  """

}
process step_2 {

  storeDir 'results/step_2'

  input:
  file(file_in) from step_1_output
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]

  output:
  file("*_processed.${version}.txt") into step_2_output

  script:
  """
  file_contents=`cat $file_in`
  sample=`echo "$file_in" | cut -d_ -f1`
  echo "\$file_contents\nAnd some more stuff" > \${sample}_processed.${version}.txt
  """

}
