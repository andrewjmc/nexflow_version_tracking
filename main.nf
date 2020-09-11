#!/usr/bin/env nextflow

Channel.fromPath( "$params.inputDir/*.txt" ).set{ files_in }
process step_1 {

  storeDir 'results/step_1'

  input:
  file(file_in) from files_in

  output:
  file("*_processed.txt") into step_1_output

  script:
  """
  file_contents=`cat $file_in`
  echo "$file_in: \$file_contents" > ${file_in.baseName}_processed.txt
  """

}
