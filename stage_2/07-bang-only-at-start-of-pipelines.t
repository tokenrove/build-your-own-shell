# mksh does not agree with this interpretation
→ echo zim | ! tr z b | grep -qc bim || echo foo⏎
≠ foo
→ ! echo zim | tr z b | grep -qc bim || echo-rot13 foo⏎
↵ sbb
