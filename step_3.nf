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

step_3_output.into( step_3_output_1, step_3_output_2 )

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
