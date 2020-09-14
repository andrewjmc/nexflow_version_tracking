process step_2 {

  storeDir 'results/step_2'

  input:
  file(file_in) from step_1_output
  val(version) from commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_2.nf".execute().text]

  output:
  file("*_processed.${version}.txt") into step_2_output
  val(version) into step_2_version

  script:
  """
  file_contents=`cat $file_in`
  sample=`echo "$file_in" | cut -d_ -f1`
  echo "\$file_contents\nAnd some more stuff" > \${sample}_processed.${version}.txt
  """

}

process step_2_code {
  storeDir 'results/step_2/code'

  input:
     val(version) from step_2_version
     path "step_2.${version}.nf" from "${workflow.projectDir}/step_2.nf"

  output:
     path("*.${version}.nf", includeInputs: true) into step_2_code

  script:
  """
    l=`grep -n "^[}]\$" *.nf | head -n1 | cut -d: -f2`
    sed -i -n "1,${l}p" *.nf
  """
}
