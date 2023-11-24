# POSIX calls these AND Lists and OR Lists
→ true && echo-rot13 foo⏎
↵ sbb
→ false && echo-rot13 foo⏎
≠ sbb
→ true && false && echo-rot13 foo⏎
≠ sbb
→ false || echo-rot13 foo⏎
↵ sbb
→ true || false || echo-rot13 foo⏎
≠ sbb
→ false || true && echo-rot13 foo⏎
↵ sbb
# we wait a bit here because some shells have an expensive
# command_not_found_handler hook; e.g. Fedora checks a package
# database.
→ nonexistent-command || echo-rot13 zim⏎
⌛
↵ mvz
