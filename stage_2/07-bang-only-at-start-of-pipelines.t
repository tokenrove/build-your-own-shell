# Would prefer to test this but mksh doesn't agree
#→ echo zim | ! tr z b | grep -qc bim || echo foo⏎
#≠ foo
→ ! echo zim | tr z b | grep -qc bim || echo-rot13 foo⏎
← sbb
