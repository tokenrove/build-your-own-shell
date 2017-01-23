# POSIX calls these AND Lists and OR Lists
→ true && echo foo⏎
← foo
→ false && echo foo⏎
≠ foo
→ true && false && echo foo⏎
≠ foo
→ false || echo foo⏎
← foo
→ true || false || echo foo⏎
≠ foo
→ false || true && echo foo⏎
← foo
