process step_1 {

  storeDir 'results/step_1'

  input:
    file(file_in) from files_in
    val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]

  output:
    file("${file_in.baseName}_processed.${version}.txt") into step_1_output
    val(version) into step_1_version

  script:
  """
    file_contents=`cat $file_in`
    echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  """

}

process step_1_code {
  storeDir 'results/step_1/code'

  input:
    val(version) from step_1_version
    path "step_1.${version}.nf" from "${workflow.projectDir}/step_1.nf"

  output:
    path("*.${version}.nf", includeInputs: true) into step_1_code

  script:
  """
    l=`grep -n "^[}]\$" *.nf | head -n1 | cut -d: -f2`
    sed -i -n "1,${l}p" *.nf
  """
}
