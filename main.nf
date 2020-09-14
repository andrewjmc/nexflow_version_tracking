#!/usr/bin/env nextflow

Channel.fromPath( "$params.inputDir/*.txt" ).set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

process step_1 {

  storeDir 'results/step_1'

  input:
    file(file_in) from files_in
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]

  output:
    file("${file_in.baseName}_processed.${version}.txt") into step_1_output
    val(version) into step_1_version

  script:
  """
    file_contents=`cat $file_in`
    echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  """

}

process step_1_code {
  storeDir 'results/step_1/code'

  input:
    val(version) from step_1_version
    path "step_1.${version}.nf" from "${workflow.projectDir}/step_1.nf"

  output:
    path("*.${version}.nf", includeInputs: true) into step_1_code

  script:
  """
    l=`grep -n "^[}]\$" *.nf | head -n1 | cut -d: -f1`
    sed -i -n "1,\${l}p" *.nf
  """
}
process step_2 {

  storeDir 'results/step_2'

  input:
  file(file_in) from step_1_output
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]

  output:
  file("*_processed.${version}.txt") into step_2_output
  val(version) into step_2_version

  script:
  """
  file_contents=`cat $file_in`
  sample=`echo "$file_in" | cut -d_ -f1`
  echo "\$file_contents\nAnd some more stuff" > \${sample}_processed.${version}.txt
  """

}

process step_2_code {
  storeDir 'results/step_2/code'

  input:
     val(version) from step_2_version
     path "step_2.${version}.nf" from "${workflow.projectDir}/step_2.nf"

  output:
     path("*.${version}.nf", includeInputs: true) into step_2_code

  script:
  """
    l=`grep -n "^[}]\$" *.nf | head -n1 | cut -d: -f1`
    sed -i -n "1,\${l}p" *.nf
  """
}
