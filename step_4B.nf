process step_4B {

  storeDir 'results/step_4B'

  input:
    tuple val(sample), file(file_in) from step_3_output_2
    file(step_4A_file) from step_4A_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_4B.nf".execute().text]
    val(prior_versions) from step_4A_cumulative_versions

  output:
    tuple val(sample), file("${sample}_processed.${prior_versions}-${version}.txt") into step_4B_output
    val(version) into s4Bv

  script:
  """
    cat $file_in $step_4A_file > ${sample}_processed.${prior_versions}-${version}.txt
  """

}

s4Bv
  .first()
  .set{ step_4B_version }

process step_4B_code {
  storeDir 'results/step_4B/code'

  input:
    val(version) from step_4B_version
    val(prior_versions) from step_4A_cumulative_versions
    path(code) from "${workflow.projectDir}/step_4B.nf"
    path(prior_code) from step_4A_cumulative_code
    val(process_name) from 'step_4B'

  output:
    path("step_4B.${version}.nf") into step_4B_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_4B_cumulative_code

  script:
    template 'nf_export_code.sh'
}

step_4A_cumulative_versions
  .merge(step_4B_version)
  .map{ it[0] + '-' + it[1] }
  .set{ step_4B_cumulative_versions }
