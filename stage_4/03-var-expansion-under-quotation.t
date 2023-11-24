→ echo "$KNOWN_VARIABLE"⏎
↵ reindeer flotilla
→ echo-argc "$KNOWN_VARIABLE"⏎
↵ 1
# zsh does not pass this test
→ echo-argc $KNOWN_VARIABLE⏎
↵ 2
→ echo-argc '$KNOWN_VARIABLE'⏎
↵ 1
→ echo '$KNOWN_VARIABLE'⏎
↵ $KNOWN_VARIABLE
