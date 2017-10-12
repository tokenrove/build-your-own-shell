# Interactivity

## Bill of Materials

`isatty`
`tcdrain`
`cfmakeraw`
`tcgetattr`
`tcsetattr`

a ring buffer
optionally a terminal control library

## Overview

This is where things get fun, and hopefully your shell gets usable.

We won't talk too much about PTYs here, but a fun next project after
this shell is to write a terminal emulator or an SSH client.

If you have access to terminfo, this will be nicer than emitting vt100
escape codes and praying.  (By the way, terminfo is a simple stack
machine, if that whets your appetite for a strange diversion.)

See chapter 18 of APUE, chapter 62 of LPI,
https://github.com/troglobit/editline,
https://github.com/nikodemus/linedit,
https://github.com/diml/lambda-term.

We assumed it before, but let's make sure that stdin is actually a tty
with `isatty`.

## Line editing

First things first, let's stop the user from backspacing over the
prompt.

Save the terminal attributes with `tcgetattr`; we'll need this to
restore things when we're done.  Make a copy of this, and then
`cfmakeraw` on this copy, and `tcsetattr` with these modified
attributes.

Now the terminal is in raw mode; you'll want to read characters one at
a time, echoing them if they're printable, and handling characters
you're interested in yourself -- start with backspace (127).  You'll
need to keep track of where you are on the screen, and move the cursor
around as characters are inserted and deleted.

When you draw the prompt, keep track of where the cursor ends up; now,
when you intercept backspace, prevent the cursor from moving before
that position.

Since you'll be keeping track of the position of the cursor, you may
want to handle SIGWINCH.

You'll want to undo this ("deprep", in readline terms) every time you
execute a foreground command, and of course when exiting the shell.

(If you want to add RPROMPT support, you're on your own.)

Now add `^A`, `^E`, `^W`, `^F`, `^B`.

## History

Keep track of each shell input (possibly multiple lines).

Now let's add `^R`, up, down, and history.

## Completion

When we receive tab (`^I`), figure out where we are in the current
input line: if we're in the command position, we'll want to offer
completions from the contents of `PATH`, otherwise we'll want to offer
completions of arbitrary files, including those in the current
directory.  If what we're over already has a `/` in it, we know where
to search, although in the command position, again, we'll only want to
complete files with the execute bit set.

To show a tab completion menu when completions are ambiguous, the
easiest thing to do is to print the completions on the following line,
and then redraw the prompt on a new line.

## Bonus:

Implement `set -o vi`.

