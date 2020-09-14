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
