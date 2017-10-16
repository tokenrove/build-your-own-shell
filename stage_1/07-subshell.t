→ pwd⏎
≠ /tmp
→ (cd /tmp; pwd)⏎
← /tmp
→ pwd⏎
≠ /tmp
→ (exit 1) && echo-rot13 foo⏎
≠ sbb
→ (exit 0 && exit 1) && echo-rot13 foo⏎
← sbb
