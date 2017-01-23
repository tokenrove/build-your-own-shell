→ echo-signal 18⏎
→ ^Z
→ echo foo⏎
← foo
→ fg⏎
← 18
→ echo-signal 2 &⏎
→ echo foo⏎
← foo
→ fg⏎
→ ^C⏎
← 2
