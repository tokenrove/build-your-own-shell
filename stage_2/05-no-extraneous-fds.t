→ list-fds⏎
← 0\n1\n2
# probably want to check a few other cases of this
→ list-fds 0<&- 2<&-⏎
← 1
# is this order specified by POSIX?  seems like you could get 0,1 here
→ list-fds 0<&- 2<&- 3</dev/null⏎
← 1\n3
