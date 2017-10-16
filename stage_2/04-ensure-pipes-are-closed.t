# This will hang in the case of a very common bug: you forget to close
# the other ends of the pipe.
→ cat </etc/passwd | cat | cat | cat >/dev/null | echo-rot13 foo⏎
← sbb
