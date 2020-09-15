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
