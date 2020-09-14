process step_1 {

  storeDir 'results/step_1'

  input:
  file(file_in) from files_in
  val(commit) from commits["git log -n 1 --pretty=format:%H -- ${workflow.projectDir}/step_1.nf".execute().text]

  output:
  file("*_processed.${commit}.txt") into step_1_output

  script:
  """
  file_contents=`cat $file_in`
  echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${commit}.txt
  """

}
