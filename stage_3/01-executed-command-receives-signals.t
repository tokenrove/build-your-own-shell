# this would be nicer if we already had $@...
→ echo-signal INT⏎
← ready
→ ^C⏎
← INT
→ echo-signal TSTP⏎
← ready
→ ^Z⏎
← TSTP
