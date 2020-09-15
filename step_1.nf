process step_1 {

  storeDir 'results/step_1'

  input:
    tuple val(sample), file(file_in) from files_in
    val(version) from branch_str + commits["${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/step_1.nf".execute().text]
    val(branch_str) from branch_str

  output:
    tuple val(sample), file("${file_in.baseName}_processed.${version}.txt") into step_1_output
    val(version) into s1v

  script:
  """
    file_contents=`cat $file_in`
    echo "$file_in: \$file_contents v2" > ${file_in.baseName}_processed.${version}.txt
  """

}

s1v
  .first()
  .set{ step_1_version }

process step_1_code {
  storeDir 'results/step_1/code'

  input:
    val(version) from step_1_version
    path(code) from "${workflow.projectDir}/step_1.nf"
    val(process_name) from "step_1"
    val(prior_versions) from ""
    val(prior_code) from ""
    val(branch_str) from branch_str

  output:
    path("step_1.${version}.nf") into step_1_code

  script:
    template 'nf_export_code.sh'
}
