# fork/exec/wait

## Ingredients

At least `fork(2)`, `execve(2)`, and `wait(2)`.

`chdir(2)`

## Instructions

Classically, the simplest possible shell is basically:

```
loop
    print "$ "; flush(stdout)
    line = getline(stdin).split()
    if eof(stdin): exit(0)
    pid = fork()
    if pid == 0:
      execvp(line)
    waitpid(pid)
```

To that, we should add at least a builtin for `cd`, which will call
`chdir(2)` with the supplied argument.  Think about why we couldn't
implement this as an external command.

We'll do a bit of extra work in this stage, compared to many simple
shell tutorials, since it will prepare us for the later stages.

To run the test suite, invoke it as `./validate /path/to/your/shell`.

### Basics

You should
 - make your shell print the `$ ` prompt;
 - accept a line of input;
 - `chdir` if the command is `cd`, otherwise
 - execute that as a command (which might be absolute, relative, or in
   `PATH`) with space-delimited arguments;
 - repeat until you receive EOF on `stdin`.

The test suite will try to execute various well-known POSIX commands
inside your shell.  Make sure actual binaries of `true`, `false`,
`ls`, and `echo` are in your PATH.

Let's also allow `\` at the end of a line as a continuation character.
Print `> ` as the prompt while reading a continued line.

About the prompt: the test suite avoids testing the specific prompt,
because it turns out this is something people like to have fun with,
but I recommend emitting at least some prompt for each of the cases I
mention, because this will make it easier for you to debug your shell,
and eventually to use it.

### Exit status and `!`

- how to get the exit status, and its general importance

If the command begins with `!` (separated by whitespace), we will
negate the exit status, which will come in handy shortly.

**Bonus:** Change the prompt to red if the last command run exited
with a non-zero status?  (Don't worry about termcap and supporting
every terminal under the sun just yet; just use [ANSI escape codes]
for now.)

[ANSI escape codes]: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

### `exit` builtin

### Lists of commands

Split your input on `;`, `&&`, and `||`.  Commands separated by any of
these are executed sequentially.  For semicolons, that's all you need
to do.

When two commands are separated by `&&`, you need to run the following
command only if the exit status of the first command is 0.  For `||`,
you'll run the second command only if the exit status is _not_ 0.

Both of these echo bar:
```
false && echo foo || echo bar
true || echo foo && echo bar
```

(The standard calls these "sequential lists", "AND lists", and "OR
lists", respectively.)

### `exec` builtin

There are ways to use each half of this `fork`/`exec` pair without the
other.  The `exec` builtin causes your shell to `exec` without
forking, which replaces the current process entirely.

This is mostly useful in scripting, where you want to throw away the
memory occupied by the shell entirely because you know the next
command is the last thing you're going to do.

The `exec` builtin has another use we will discuss in the next stage.

### Subshells

Now, for the other half of `fork`/`exec` -- what if we `fork` (and
`wait`), but don't `exec`?  If a command is surrounded in parenthesis,
we fork, and in the parent, wait for the child as we normally would,
and in the child, we process the command normally.

This allows us to do things in an isolated shell environment.

```
(cd /tmp && pwd); pwd
```

Should print `/tmp` and whatever your previous working directory was.

(This isn't that important, relative to the other things we're going
to talk about, but having enough of a parser in place that you can
read the parentheses correctly will be helpful for the following
stages.)

## Notes

This is actually, along with job control later, the most difficult
part of writing a shell in any language but C, because such languages
usually provide features like threads and signal handling out of the
box.  They also end up opening fds that might not have CLOEXEC set.

### threads

`fish` is multithreaded.  Ponder the following comment from
ridiculous_fish:

> An example of a problem we encountered: what if execve() fails? Then
> we want to print an error message, based on the value of
> errno. perror() is the preferred way to do this. But on Linux,
> perror() calls into gettext to show a localized message, and gettext
> takes a lock, and then you deadlock.

### `posix_spawn`

As an alternative to the combination of `fork` and `exec`, it would
make sense to use `posix_spawn(3)`.  On many systems, this provides a
"safe" wrapper around `vfork(2)`, which can be much more efficient.
(To watch someone basically reinvent it, see
["A much faster popen and system implementation for Linux"])

One of the reasons I don't encourage it here is that it ends up being
much more complex.  Another quote from the author of fish:

> The brilliance of fork/exec is in the realization that the tasks you
> do during process creation are the same as the tasks you do during
> normal execution, and therefore you can just re-use those functions.

Compare the various libc implementations of `posix_spawn`:
 - [glibc's generic implementation of posix_spawn]
 - [glibc's Linux implementation of posix_spawn]
 - [FreeBSD's posix_spawn] (copied by many others, including newlib)
 - [musl's posix_spawn]

See also https://ewontfix.com/7/

["A much faster popen and system implementation for Linux"]: https://blog.famzah.net/2009/11/20/a-much-faster-popen-and-system-implementation-for-linux/
[FreeBSD's posix_spawn]: https://github.com/freebsd/freebsd/blob/master/lib/libc/gen/posix_spawn.c
[glibc's generic implementation of posix_spawn]: https://github.com/bminor/glibc/blob/master/sysdeps/posix/spawni.c
[glibc's Linux implementation of posix_spawn]: https://github.com/bminor/glibc/blob/master/sysdeps/unix/sysv/linux/spawni.c
[musl's posix_spawn]: https://github.com/bminor/musl/blob/master/src/process/posix_spawn.c
