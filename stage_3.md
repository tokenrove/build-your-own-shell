# Job Control and Signals

## Reagents

 - [`sigaction`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/sigaction.html)
 - [`tcsetpgrp`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/tcsetpgrp.html)
 - [`setpgid`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/setpgrp.html)
 - [`tcgetpgrp`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/tcgetpgrp.html)
 - [`killpg`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/killpg.html)
 - [`isatty`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/isatty.html)

## Synthesis

An outline:

```
open /dev/tty
ignore SIGTTOU in the shell
tcgetpgrp to get the current process group
create new pgrp (setpgid) with first child's PID
setpgid and tcsetpgrp in both child and parent
when returning control to the shell, tcsetpgrp to shell's pgrp
```

See APUE chapter 9, and glibc's [Implementing a Job Control Shell].

[Implementing a Job Control Shell]: https://www.gnu.org/software/libc/manual/html_node/Implementing-a-Shell.html

### Background processes

Extend your input handling to separate lines by `&`.  Commands ending
with `&` are run in the background, which means you aren't going to
`wait()` on them after you've forked.  Instead, you have a few choices
of how to deal with your background processes.

When a child dies, the parent is notified with a signal, `SIGCHLD`.
Signals and the complications and dangers they present are too huge a
topic for this workshop, so I recommend APUE chapter 10 and LPI
chapters 20-22.

You may want an event loop that can deal with signals for you, like
`libev`.  For diving deeper, take a look at `sigfd` on Linux and
`kqueue`'s signal support on BSDs.

- different ways of dealing with waiting for children
- zombies
- orphaned process groups

### Process groups

A pipeline forms a single process group.  This is called a *job*.

When you create a pipeline, the first child should put itself in a new
process group, with `setpgid(getpid(), getpid())`, and every other
child should `setpgid(getpid(), pgrp_of_pipeline)` (you'll need the
parent to keep track of the first child's PID and make sure the other
children have access to it).  You should do this in both the parent
and the child, to avoid races.

This is also where those negative arguments to `kill(2)` come in
handy: when you send `SIGCONT`, you'll want to send it to the whole
process group, not just the child alone.

### Terminal foreground process group

How do chords like `^C` know to interrupt the foreground process and
not the shell?  `tcsetpgrp` tells the tty driver, which is what
translates hitting `^C` into sending `SIGINT`, that the given process
group is the one in charge of the terminal right now.

This is also prone to races, so you'll need to `tcsetpgrp` in both the
parent and the child.

And crucially, you'll need to `tcsetpgrp` back to the shell's process
group every time control returns to the shell: when a foreground child
exits or is stopped.

### Signals

We'll need to handle `SIGTSTP`, `SIGTTIN`, `SIGTTOU`, and we'll end up
sending `SIGCONT`.

The built-ins `fg` and `bg` should send `SIGCONT` to the current job
(its process group), doing `waitpid` in the former case and continuing
onwards in the latter.

From [hush.c:1640](https://git.busybox.net/busybox/tree/shell/hush.c#n1640)
```c
/* Basic theory of signal handling in shell
[...]
 * Signals are handled only after each pipe ("cmd | cmd | cmd" thing)
 * is finished or backgrounded. It is the same in interactive and
 * non-interactive shells, and is the same regardless of whether
 * a user trap handler is installed or a shell special one is in effect.
 * ^C or ^Z from keyboard seems to execute "at once" because it usually
 * backgrounds (i.e. stops) or kills all members of currently running
 * pipe.
[...]
 * Commands which are run in command substitution ("`cmd`")
 * have SIGTTIN, SIGTTOU, SIGTSTP set to SIG_IGN.
 *
 * Ordinary commands have signals set to SIG_IGN/DFL as inherited
 * by the shell from its parent.
 *
 * Signals which differ from SIG_DFL action
 * (note: child (i.e., [v]forked) shell is not an interactive shell):
 *
 * SIGQUIT: ignore
 * SIGTERM (interactive): ignore
 * SIGHUP (interactive):
 *    send SIGCONT to stopped jobs, send SIGHUP to all jobs and exit
 * SIGTTIN, SIGTTOU, SIGTSTP (if job control is on): ignore
 *    Note that ^Z is handled not by trapping SIGTSTP, but by seeing
 *    that all pipe members are stopped. Try this in bash:
 *    while :; do :; done - ^Z does not background it
 *    (while :; do :; done) - ^Z backgrounds it
 * SIGINT (interactive): wait for last pipe, ignore the rest
 *    of the command line, show prompt. NB: ^C does not send SIGINT
 *    to interactive shell while shell is waiting for a pipe,
 *    since shell is bg'ed (is not in foreground process group).
```

### Job control

Keep track of backgrounded jobs.  `fg` brings the most recent
backgrounded job into the foreground (do the `tcsetpgrp` dance, send
`SIGCONT` if it was stopped, and `waitpid` for it).  `^Z` will send
`SIGTSTP` to a foreground job and suspend it; `waitpid` will tell you
the child got suspended, so don't just forget about it; keep track of
it as a stopped job.  `bg` puts the most recently stopped job into the
background: just send `SIGCONT` to it (and keep track of it), but
don't give it back the TTY.

See https://blog.nelhage.com/2010/01/a-brief-introduction-to-termios-signaling-and-job-control/

For fun, you may want to implement `jobs` (to list running jobs).

From the bash source (jobs.c):

```c
          /* Set the process group before trying to mess with the terminal's
             process group.  This is mandated by POSIX. */
          /* This is in accordance with the Posix 1003.1 standard,
             section B.7.2.4, which says that trying to set the terminal
             process group with tcsetpgrp() to an unused pgrp value (like
             this would have for the first child) is an error.  Section
             B.4.3.3, p. 237 also covers this, in the context of job control
             shells. */
          if (setpgid (mypid, pipeline_pgrp) < 0)
            sys_error (_("child setpgid (%ld to %ld)"), (long)mypid, (long)pipeline_pgrp);
```

### `SIGTTIN`/`SIGTTOU`

about sigttin/ttou: http://curiousthing.org/sigttin-sigttou-deep-dive-linux

### SIGHUP

When you exit, you should send SIGHUP to your children.  But first,
you will want to make sure they're not stopped, so send `SIGCONT` to
all of them first, then HUP them.

You may implement the builtin `disown` to remove a job from the list
of active jobs, so it won't be sent HUP in this case.

## Notes

Interaction with builtins is again a strange topic.  Compare how
various shells handle sending `^Z` to `sleep 20 | false` and then
checking the exit code.  (This example is from `hush`.  All of `bash`,
`zsh`, and `mksh` handle this differently for me.)

Writing this workshop has convinced me that a shell should have as few
builtins as possible, and that much of the scripting behavior should
be provided as "combinators" that operate on commands.
