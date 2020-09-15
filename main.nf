#!/usr/bin/env nextflow

Channel
  .fromPath( "$params.inputDir/*.txt" )
  .map{ [it.baseName, it] }
  .set{ files_in }

i=0
commits="./get_git_commits.sh".execute().text.tokenize("\n").reverse().collectEntries{ [it, ++i] }

process step_1 {

  storeDir 'results/step_1'

  input:
    tuple val(sample), file(file_in) from files_in
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]

  output:
    tuple val(sample), file("${file_in.baseName}_processed.${version}.txt") into step_1_output
    val(version) into s1v

  script:
  """
    file_contents=`cat $file_in`
    echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  """

}

s1v
  .first()
  .set{ step_1_version }

process step_1_code {
  storeDir 'results/step_1/code'

  input:
    val(version) from step_1_version
    path(code) from "${workflow.projectDir}/step_1.nf"
    val(process_name) from "step_1"
    val(prior_versions) from ""
    val(prior_code) from ""

  output:
    path("step_1.${version}.nf") into step_1_code

  script:
    template 'nf_export_code.sh'
}
process step_2 {

  storeDir 'results/step_2'

  input:
    tuple val(sample), file(file_in) from step_1_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]
    val(prior_versions) from step_1_version

  output:
    tuple val(sample), file("${sample}_processed.${prior_versions}-${version}.txt") into step_2_output
    val(version) into s2v

  script:
  """
    file_contents=`cat $file_in`
    sample=`echo "$file_in" | cut -d_ -f1`
    echo "\$file_contents\nAnd some more stuff\nThis change made for fun" > \${sample}_processed.${prior_versions}-${version}.txt
  """

}

s2v
  .first()
  .set{ step_2_version }

process step_2_code {
  storeDir 'results/step_2/code'

  input:
    val(version) from step_2_version
    val(prior_versions) from step_1_version
    path(code) from "${workflow.projectDir}/step_2.nf"
    path(prior_code) from step_1_code
    val(process_name) from "step_2"

  output:
    path("step_2.${version}.nf") into step_2_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_2_cumulative_code

  script:
    template 'nf_export_code.sh'
}

step_1_version
  .merge(step_2_version)
  .map{ it[0] + '-' + it[1] }
  .set{ step_2_cumulative_versions }
process step_3 {

  storeDir 'results/step_3'

  input:
    tuple val(sample), file(file_in) from step_2_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_3.nf".execute().text]
    val(prior_versions) from step_2_cumulative_versions

  output:
    tuple val(sample), file("${sample}_processed.${prior_versions}-${version}.txt") into step_3_output
    val(version) into s3v

  script:
  """
    file_contents=`cat $file_in`
    sample=`echo "$file_in" | cut -d_ -f1`
    echo "\$file_contents\nAnd more stuff again" > \${sample}_processed.${prior_versions}-${version}.txt
  """

}

s3v
  .first()
  .set{ step_3_version }

process step_3_code {
  storeDir 'results/step_3/code'

  input:
    val(version) from step_3_version
    val(prior_versions) from step_2_cumulative_versions
    path(code) from "${workflow.projectDir}/step_3.nf"
    path(prior_code) from step_2_cumulative_code
    val(process_name) from 'step_3'

  output:
    path("step_3.${version}.nf") into step_3_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_3_cumulative_code

  script:
    template 'nf_export_code.sh'
}

step_2_cumulative_versions
  .merge(step_3_version)
  .map{ it[0] + '-' + it[1] }
  .set{ step_3_cumulative_versions }
process step_4A {

  storeDir 'results/step_4A'

  input:
    file(file_in) from step_3_output.map{ it[1] }.collect()
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_4A.nf".execute().text]
    val(prior_versions) from step_3_cumulative_versions

  output:
    file("4A_output.${prior_versions}-${version}.txt") into step_4A_output
    val(version) into step_4A_version

  script:
  """
    head -c 1 *.txt | grep -v "^==>" | tr -d "\n" > 4A_output.${prior_versions}-${version}.txt
  """

}

process step_4A_code {
  storeDir 'results/step_4A/code'

  input:
    val(version) from step_4A_version
    val(prior_versions) from step_3_cumulative_versions
    path(code) from "${workflow.projectDir}/step_4A.nf"
    path(prior_code) from step_3_cumulative_code
    val(process_name) from 'step_4A'

  output:
    path("step_4A.${version}.nf") into step_4A_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_4A_cumulative_code

  script:
    template 'nf_export_code.sh'
}

step_3_cumulative_versions
  .merge(step_4A_version)
  .map{ it[0] + '-' + it[1] }
  .set{ step_4A_cumulative_versions }
