process step_2 {

  storeDir 'results/step_2'

  input:
  val(sample), file(file_in) from step_1_output
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]

  output:
  file("*_processed.${version}.txt") into step_2_output

  script:
  """
  file_contents=`cat $file_in`
  echo "\$file_contents\nAnd some more stuff" > ${sample}_processed.${version}.txt
  """

}
