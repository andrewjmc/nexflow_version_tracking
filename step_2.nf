process step_2 {

  storeDir 'results/step_2'

  input:
    file(file_in) from step_1_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]
    val(prior_versions) from step_1_cumulative_versions

  output:
    file("*_processed.${version}.txt") into step_2_output
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
    val(version) from step_2_version
    val(prior_versions) from step_2_cumulative_versions_dup
    path "step_2.${version}.nf" from "${workflow.projectDir}/step_2.nf"
    file(prior_code) from step_1_code

  output:
    path("step_2.${version}.nf", includeInputs: true) into step_2_code
    path("cumulative_code.*.sh") into step_2_cumulative_code

  script:
  """
    cat $prior_code step_2.${version}.sh > cumulative_code.${prior_versions}-${version}.sh
  """
}
