process step_2 {

  storeDir 'results/step_2'

  input:
    file(file_in) from step_1_output
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]
    val(prior_versions) from step_1_version

  output:
    file("*_processed.${prior_versions}-${version}.txt") into step_2_output
    val(version) into s2v

  script:
  """
    file_contents=`cat $file_in`
    sample=`echo "$file_in" | cut -d_ -f1`
    echo "\$file_contents\nAnd some more stuff" > \${sample}_processed.${prior_versions}-${version}.txt
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
    file(code) from "${workflow.projectDir}/step_2.nf"
    file(prior_code) from step_1_code

  output:
    path("step_2.${version}.nf") into step_2_code
    path("cumulative_code.${prior_versions}-${version}.nf") into step_2_cumulative_code

  script:
  """
    l=`grep -n "^[}]\$" $code | head -n1 | cut -d: -f1`
    sed -n "1,\${l}p" $code > step_2.${version}.nf
    cat $prior_code step_2.${version}.nf > cumulative_code.${prior_versions}-${version}.nf
  """
}

step_1_version
  .merge(step_2_version)
  .map{ it[0] + '-' + it[1] }
  .first()
  .set{ step_2_cumulative_versions }
