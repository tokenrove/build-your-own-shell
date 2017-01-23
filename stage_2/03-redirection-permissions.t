# NB stdin/out/err when connected to a terminal is usually rw
→ fd-perms 0 </dev/null⏎
← r
→ fd-perms 0 <>/dev/null⏎
← rw
# it's tricky to test fd 1 without losing the output.  we could have
# an exit status instead, with tools called is-writable and
# is-readable, but meh.
→ fd-perms 3 3>/dev/null⏎
← w
# An Arrow in Heart
→ fd-perms 3 3</dev/null⏎
← r
→ fd-perms 3 3<>/dev/null⏎
← rw
