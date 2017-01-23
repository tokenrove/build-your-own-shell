→ export EXPORTED_VAR; EXPORTED_VAR=foo; local_var=bar⏎
→ sh -c 'echo $EXPORTED_VAR$local_var'⏎
← foo
