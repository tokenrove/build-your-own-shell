# this would be nicer if we already had $@...
→ echo-signal 2⏎
→ ^C⏎
← 2
→ cat⏎
→ ^\⏎echo foo⏎
← foo
→ echo-signal 20⏎
→ ^Z⏎
← 20
