commit=`${workflow.projectDir}/get_last_commit_for_file.sh ${workflow.projectDir}/${process_name}.nf`
l=`grep -n "^[}]\$" $code | head -n1 | cut -d: -f1`
echo "/*\$commit*/" > ${process_name}.${version}.nf
sed -n "1,\${l}p" $code >> ${process_name}.${version}.nf
if [ ! -z "$prior_versions" ]; then
  cat $prior_code ${process_name}.${version}.nf > cumulative_code.${prior_versions}-${version}.nf
fi
