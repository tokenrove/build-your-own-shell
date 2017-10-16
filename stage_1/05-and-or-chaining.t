# POSIX calls these AND Lists and OR Lists
→ true && echo-rot13 foo⏎
← sbb
→ false && echo-rot13 foo⏎
≠ sbb
→ true && false && echo-rot13 foo⏎
≠ sbb
→ false || echo-rot13 foo⏎
← sbb
→ true || false || echo-rot13 foo⏎
≠ sbb
→ false || true && echo-rot13 foo⏎
← sbb
→ nonexistent-command || echo-rot13 zim⏎
← mvz
