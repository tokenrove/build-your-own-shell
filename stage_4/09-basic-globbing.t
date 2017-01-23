→ touch foo fob bar barf⏎
→ echo fo?⏎
← fob foo
→ echo f?o⏎
← foo
→ echo bar*⏎
← bar barf
→ echo *b*⏎
← bar barf fob
# no expansion when quoted
→ echo "f*"⏎
← f*
→ echo fo'?'⏎
← fo?
