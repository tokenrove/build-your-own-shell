# Interactivity

## Bill of Materials

`isatty`
`tcdrain`

a ring buffer
optionally a terminal control library

##

We won't talk too much about PTYs here, but a fun next project after
this shell is to write a terminal emulator or an SSH client.

## First steps

open /dev/tty
ignore SIGTTOU in the shell
tcgetpgrp to get the current process group
tcsetpgrp in both child and parent, first child's PID
when returning control to the shell, tcsetpgrp to shell's pgrp

##

First things first, let's stop the user from backspacing over the prompt.

Now let's add `^R`, up, down, and history.

## Bonus:

Implement `set -o vi`.

# Completion

To show a tab completion menu when completions are ambiguous, the
easiest thing to do is to print the completions on the following line,
and then redraw the prompt on a new line.
