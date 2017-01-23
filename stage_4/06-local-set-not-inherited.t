→ var=foo echo $var⏎
≠ foo
→ var=foo; echo $var⏎
← foo
→ sh -c 'echo $var'⏎
≠ foo
