# we're started in a temp directory
→ echo zim > foo && cat foo | tr n-za-m a-z⏎
← mvz
→ cat foo⏎
← zim
→ echo a > foo ; echo b > foo ; cat foo⏎
← b
# NB echo -n isn't portable...
→ echo -n a > foo ; echo b >> foo ; cat foo⏎
← ab
→ cat < /non-existent-file || echo-rot13 foo⏎
← sbb
→ cat /non-existent-file 2>foo || grep -c . <foo⏎
← 1
→ echo quux > foo && cat < foo⏎
← quux
→ echo quux >foo && echo -n blah <>foo && cat <foo⏎
← blahquux
→ echo bar >foo && cat <>foo⏎
← bar
→ echo mitten >foo && echo -n k 1<>foo && cat foo⏎
← kitten
