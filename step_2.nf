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
