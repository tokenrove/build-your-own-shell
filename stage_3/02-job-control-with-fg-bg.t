→ echo-signal CONT⏎
← ready
→ ^Z
→ echo-rot13 foo⏎
← sbb
→ fg⏎
← CONT
→ echo-signal INT &⏎
← ready
→ echo-rot13 foo⏎
← sbb
→ fg⏎
→ ^C⏎
← INT
