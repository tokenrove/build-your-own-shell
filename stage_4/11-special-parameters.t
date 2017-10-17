→ true; echo $?⏎
← 0
→ false; echo $?⏎
← 1
→ echo-signal TERM &⏎
← ready
→ kill $!⏎
← TERM
