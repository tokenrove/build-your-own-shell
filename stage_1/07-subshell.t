→ pwd⏎
≠ /tmp\n
→ (cd /tmp; pwd)⏎
↵ /tmp\n
→ pwd⏎
≠ /tmp\n
→ (exit 1) && echo-rot13 foo⏎
≠ sbb\n
→ (exit 0 && exit 1) && echo-rot13 foo⏎
↵ sbb\n
