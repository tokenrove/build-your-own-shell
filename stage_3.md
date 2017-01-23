# Job Control and Signals

## Reagents

`sigsetaction`, `sigwait`, `kill`

`tcsetpgrp`, `setpgid`, `tcgetpgrp`, `killpg`

## Synthesis

Extend your input handling to separate lines by `&` and `;`.

A pipeline forms a single process group.

You may want an event loop that can deal with signals for you, like
`libev`.  For diving deeper, take a look at `sigfd` on Linux and
`kqueue`'s signal support on BSDs.

We'll need to handle `SIGTSTP`, `SIGTTIN`, `SIGTTOU`, and we'll end up
sending `SIGCONT`.

The built-ins `fg` and `bg` should send `SIGCONT` to the current job,
doing `waitpid` in the former case and continuing onwards in the
latter.

See https://blog.nelhage.com/2010/01/a-brief-introduction-to-termios-signaling-and-job-control/

For fun, you may want to implement `jobs` (to list running jobs).

about sigttin/ttou: http://curiousthing.org/sigttin-sigttou-deep-dive-linux

### SIGHUP

When you exit, you should send SIGHUP to your children.  But first,
you will want to make sure they're not stopped, so continue all your
jobs then HUP them.

You may implement the builtin `disown` to remove a job from the list
of active jobs, so it won't be sent HUP in this case.

##

Interaction with builtins is again a strange topic.  Compare how
various shells handle sending `^Z` to `sleep 20 | false` and then
checking the exit code.  (This example is from `hush`.  All of `bash`,
`zsh`, and `mksh` handle this differently for me.)

Writing this workshop has convinced me that a shell should have as few
builtins as possible, and that much of the scripting behavior should
be provided as "combinators" that operate on commands.
