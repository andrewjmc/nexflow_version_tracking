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
    val(version) from step_1_version.first()
    path "step_1.${version}.nf" from "${workflow.projectDir}/step_1.nf"

  output:
    path("*.${version}.nf", includeInputs: true, followLinks: true) into step_1_code
    val(version) into step_1_cumulative_versions

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
    val(prior_versions) from step_1_cumulative_versions

  output:
    file("*_processed.${prior_versions}-${version}.txt") into step_2_output
    val(version) into step_2_version
    val(prior_versions) into step_1_cumulative_versions_dup

  script:
  """
    file_contents=`cat $file_in`
    sample=`echo "$file_in" | cut -d_ -f1`
    echo "\$file_contents\nAnd some more stuff" > \${sample}_processed.${prior_versions}-${version}.txt
  """

}

process step_2_code {
  storeDir 'results/step_2/code'

  input:
    val(version) from step_2_version.first()
    val(prior_versions) from step_1_cumulative_versions_dup.first()
    path "step_2.${version}.nf" from "${workflow.projectDir}/step_2.nf"
    file(prior_code) from step_1_code

  output:
    path("step_2.${version}.nf", includeInputs: true, followLinks: true) into step_2_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_2_cumulative_code
    val(version) into step_2_version_dup
    val(prior_versions) into step_1_cumulative_versions_dup2

  script:
  """
    cat $prior_code step_2.${version}.nf > cumulative_code.${prior_versions}-${version}.nf
  """
}

step_1_cumulative_versions_dup2
  .merge(step_2_version_dup)
  .map{ it[0] + '-' + it[1] }
  .set{ step_2_cumulative_versions }
process step_3 {

  storeDir 'results/step_3'

  input:
    file(file_in) from step_2_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_3.nf".execute().text]
    val(prior_versions) from step_2_cumulative_versions

  output:
    file("*_processed.${prior_versions}-${version}.txt") into step_3_output
    val(version) into step_3_version
    val(prior_versions) into step_2_cumulative_versions_dup

  script:
  """
    file_contents=`cat $file_in`
    sample=`echo "$file_in" | cut -d_ -f1`
    echo "\$file_contents\nAnd more stuff again" > \${sample}_processed.${prior_versions}-${version}.txt
  """

}

process step_3_code {
  storeDir 'results/step_3/code'

  input:
    val(version) from step_3_version.first()
    val(prior_versions) from step_2_cumulative_versions_dup.first()
    path "step_3.${version}.nf" from "${workflow.projectDir}/step_3.nf"
    file(prior_code) from step_2_cumulative_code

  output:
    path("step_3.${version}.nf", includeInputs: true, followLinks: true) into step_3_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_3_cumulative_code
    val(version) into step_3_version_dup
    val(prior_versions) into step_2_cumulative_versions_dup2

  script:
  """
    cat $prior_code step_3.${version}.nf > cumulative_code.${prior_versions}-${version}.nf
  """
}

step_2_cumulative_versions_dup2
  .merge(step_3_version_dup)
  .map{ it[0] + '-' + it[1] }
  .set{ step_3_cumulative_versions }
