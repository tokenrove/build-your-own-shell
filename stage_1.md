# fork/exec/wait

## Ingredients

 - [`fork(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/fork.html)
   ([Linux](http://man7.org/linux/man-pages/man2/fork.2.html),
   [FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=fork&manpath=FreeBSD+11.1-RELEASE+and+Ports))
 - [`execve(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/exec.html)
 - [`wait(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/wait.html)
 - [`chdir(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/chdir.html)

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

(Warning: note that most of these functions can fail; you'll want
error handling in your actual code.)

We'll do a bit of extra work in this stage, compared to many simple
shell tutorials, since it will prepare us for the later stages.

### Basics

You should
 - make your shell print the `$ ` prompt;
 - accept a line of input, and split it on space;
 - if the first word is a builtin (a command your shell will handle
   itself instead of executing an external program), call it;
   otherwise
 - execute that as a command with space-delimited arguments;
 - when you receive EOF on `stdin` instead of a command, exit.

### Executing a command

First, we `fork`, which creates a child process whose state is a copy
of our shell's; the memory looks the same, and any file descriptors
open are the same.  After the fork, there are two parallel universes
happening: the parent (who gets the process ID of the child from
`fork`) and the child (who gets 0 from `fork`).

In the child, we `execve` the command we want to run, with its
arguments; this replaces the running process (the child copy of the
shell) with the new command.  So now we have both our shell and the
command running, and the shell knows the process ID of the command.
(See Patrick Mooney's talk [On Wings of
exec(2)](https://systemswe.love/archive/minneapolis-2017/patrick-mooney)
for deeper details of what happens after we `execve`.)

The parent now waits for the child to complete; we do this with
`wait`.  This lets the shell sleep while the command runs, and wakes
us up with the exit status of the command.

This part is explained in a lot of detail in the resources listed in
[the main README](README.md), so if this isn't clear, please refer to
the books and tutorials cited.

### Running the tests

This should be enough to get at least the first test of stage 1 to
pass.  Run `./validate ../path-to-my-shell/my-shell` and see how far
you get.

The test suite will try to execute various well-known POSIX commands
inside your shell.  Make sure actual binaries of `true`, `false`,
`cat`, `pwd`, and `echo` are in `/bin`.

About the prompt: the test suite avoids testing the specific prompt,
because it turns out this is something people like to have fun with,
but I recommend emitting at least some prompt for each of the cases I
mention, because this will make it easier for you to debug your shell,
and eventually to use it.  Unfortunately, if your default prompt and
display is too elaborate (e.g.: `zsh` with RPROMPT, `fish`), the tests
may not work, as they are not terribly robust.

### The `cd` builtin

To that, we should add at least a builtin for `cd`, which will call
`chdir(2)` with the supplied argument.  Think about why we couldn't
implement this as an external command.  If you're not sure, try
implementing `cd` as a standalone binary that invokes `chdir` and see
what happens.  You can exec `pwd` or call `getcwd(3)` to find out the
current directory: you might want to print it as part of your prompt.

### Searching `PATH`

We don't want to have to type the explicit path to every command
you're executing.  One of the crucial conveniences of every shell is
that, if we find an unqualified command name (one that doesn't contain
the `/` character), we look for it in every directory specified in the
`PATH` environment variable.

Many languages provide versions of `exec` that do some of this extra
work for you.  That's probably fine as long as you know who is
responsible for what.  When you add completion in stage 5, you'll want
to be able to search the path yourself.

We'll talk more about the enviroment in stage 4.  For now, you can use
whatever your language provides for accessing environment variables
(`getenv(3)` in C) to get the value of `PATH`, then split it on the
`:` character to get a list of directories to search.

For a more rigorous specification, see [Command Search and Execution]
in the POSIX standard.  (This also tells you when you're allowed to
cache the location of a command.)  `PATH` itself is described in
[Other Environment Variables].

[Command Search and Execution]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_01_01
[Other Environment Variables]: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html#tag_08_03

### Exit status and `!`

We mentioned that you get the exit status of the child from `wait`.
Don't just throw this away; this will be a key part of the shell's
power, and it's why there are commands like `/bin/true` and
`/bin/false`.

There is an unfortunate amount of information packed into the status
returned to us by `wait`, but we're only interested in *exit status*
right now.  The Unix convention is that a zero exit status represents
success, and any non-zero exit status represents failure.

If the first word we read is `!`, we negate the exit status of what
follows.  Note that's word, not character, so `! true` returns a
non-zero exit code, but `!true` is not defined in POSIX, and is
usually part of a history mechanism in `ksh` descendents.

**Bonus:** Change the prompt to red if the last command run exited
with a non-zero status?  (Don't worry about termcap and supporting
every terminal under the sun just yet; just use [ANSI escape codes]
for now.)

[ANSI escape codes]: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

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

The standard calls these *sequential lists*, *AND lists*, and *OR
lists*, respectively.  See section 2.9.3, [Lists].  We'll look at
*asynchronous lists* in stage 3.

(If you want to add support for compound lists surrounded by braces,
go ahead, but I didn't consider them important enough for an
interactive shell to bother testing them.

[Lists]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_03

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
`wait`), but don't `exec`?  If a command is surrounded in parentheses,
we fork, and in the parent, wait for the child as we normally would,
and in the child, we process the command normally.

This allows us to do things in an isolated shell environment.

```
(cd /tmp && pwd); pwd
```

Should print `/tmp` and whatever your previous working directory was.

This isn't that important, relative to the other things we're going to
talk about, but having enough of a parser in place that you can read
the parentheses correctly will be helpful for the following stages.

### Line continuation

Let's allow `\` at the end of a line as a continuation character.
Print `> ` as the prompt while reading a continued line.

Likewise, if a line ends with `&&` or `||`, you'll want to continue
reading on the next line as part of the same list.

### Aside: parsing

See [Token Recognition] in the standard.  Writing a tokenizer that
follows this, ignoring the parts we aren't doing yet, will make
writing your parser easier.  I'll expand this section more, shortly.

[Token Recognition]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_03

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

### Further Reading

Stevens, APUE, chapter 8.
Kerrisk, LPI, chapters 24 through 28.

["A much faster popen and system implementation for Linux"]: https://blog.famzah.net/2009/11/20/a-much-faster-popen-and-system-implementation-for-linux/
[FreeBSD's posix_spawn]: https://github.com/freebsd/freebsd/blob/master/lib/libc/gen/posix_spawn.c
[glibc's generic implementation of posix_spawn]: https://github.com/bminor/glibc/blob/master/sysdeps/posix/spawni.c
[glibc's Linux implementation of posix_spawn]: https://github.com/bminor/glibc/blob/master/sysdeps/unix/sysv/linux/spawni.c
[musl's posix_spawn]: https://github.com/bminor/musl/blob/master/src/process/posix_spawn.c
