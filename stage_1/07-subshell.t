→ pwd⏎
≠ /tmp
→ (cd /tmp; pwd)⏎
← /tmp
→ pwd⏎
≠ /tmp
→ (exit 1) && echo foo⏎
≠ foo
→ (exit 0 && exit 1) && echo foo⏎
← foo
