process step_1 {

  storeDir 'results/step_1'

  input:
  file(file_in) from files_in
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]
  path "step_1.${version}.nf" from "${workflow.projectDir}/step_1.nf"

  output:
  file("${file_in.baseName}_processed.${version}.txt") into step_1_output
  path("*.${version}.nf", includeInputs: true) into step_1_code

  script:
  """
  file_contents=`cat $file_in`
  echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  #mv step_1.nf step_1.${version}.nf
  """

}
