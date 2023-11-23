# Files and Pipes

## Dramatis Personae

 - [`dup2(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/dup.html)
   ([Linux](http://man7.org/linux/man-pages/man2/dup2.2.html),
   [FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=dup2&sektion=2&manpath=FreeBSD+11.1-RELEASE+and+Ports))
 - [`pipe(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/pipe.html)
   ([Linux](http://man7.org/linux/man-pages/man2/pipe.2.html),
    [FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=pipe&sektion=2&manpath=FreeBSD+11.1-RELEASE+and+Ports))
 - [`open(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/open.html)
   ([Linux](http://man7.org/linux/man-pages/man2/open.2.html),
    [FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=open&sektion=2&manpath=FreeBSD+11.1-RELEASE+and+Ports))
 - [`close(2)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/close.html)
   ([Linux](http://man7.org/linux/man-pages/man2/close.2.html),
    [FreeBSD](https://www.freebsd.org/cgi/man.cgi?query=close&sektion=2&manpath=FreeBSD+11.1-RELEASE+and+Ports))

## Prologue

POSIX specifies that, by default, the file descriptors 0, 1, and 2
correspond to standard input (stdin), output (stdout), and error
(stderr).  We'll use this fact to implement the Unix shell's greatest
feature: pipes and redirections.

First, we'll add a bit more syntax.  This is where a simple parsing
framework might start to be useful.  If you're planning to use a
parser generator, consider [what Chet Ramey has to say] about bash and
bison:

> One thing I've considered multiple times, but never done, is
> rewriting the bash parser using straight recursive-descent rather
> than using bison. I once thought I'd have to do this in order to
> make command substitution conform to Posix, but I was able to
> resolve that issue without changes that extensive. Were I starting
> bash from scratch, I probably would have written a parser by
> hand. It certainly would have made some things easier.

You've already broken input up into lists; within each list, you have
conceptually one *pipeline*, which might be several commands connected
together.  You'll need to split these pipelines by occurrances of `|`,
and for each command, find expressions of the form `n< path`, `n>
path`, and `n>> path`, where `n` is an optional integer.  They don't
get passed to the underlying command.

If you'd like to handle quoting now, you might find it handy to look
at the [POSIX shell grammar] specification.  I don't think you
actually need to do this yet, though.  Just consider in your design
that splitting on whitespace won't be enough.

Note that if the last token read is a pipe, you'll need to continue
reading the next line, just like with `\`, `||`, and `&&`.

[POSIX shell grammar]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_10
[what Chet Ramey has to say]: http://www.aosabook.org/en/bash.html

## Act 1

Adjust your execution function to execute the pipeline serially,
opening pipes and adjusting fds as appropriate:

For each pair of commands connected via pipes, call `pipe(2)` and
prepare to replace fd 1 (`stdout`) on the left-hand side with
`pipefd[0]`, and fd 0 (`stdin`) on the right-hand side with
`pipefd[1]`.

For each in/out redirection (`<` and friends), you'll need to
`open(2)` the path given in a suitable mode.  Read (`O_RDONLY`) for
`<`, write (`O_CREAT|O_TRUNC|O_WRONLY`) for `>`, read-write for `<>`,
and append (`O_CREAT|O_APPEND|O_WRONLY`) for `>>`.

The fd duplication operators `<&` and `>&` take either an fd or `-` as
their second operand, and either duplicate the corresponding fd, or
close it in the case of `-`.

Remember our discussion of `posix_spawn` in [stage 1](../stage_1)?
Now we get to see the kind of operations it has to support, and why
it's so convenient to have control of the child after `fork(2)`.

After forking, use `dup2(2)` to assign the fds you need to redirect.

Execute the command and keep track of the pid, but don't wait for it,
except for the final command in the pipeline.  Close any fds you don't
need as soon as possible.

*Common bug:* the test `echo foo | cat | cat`, which should execute
immediately, will hang if you've forgotten to close some ends of pipes
somewhere.

In some languages you may find it simpler to structure this around a
recursive function, that recurses at each pipeline encountered.

The following table summarizes the fd redirections:

| operator | default fd | operation |
| --- | --- | --- |
| _[n]_`<`_f_ | 0 | open _f_ `O_RDONLY` |
| _[n]_`>`_f_ | 1 | open _f_ `O_CREAT \| O_TRUNC \| O_WRONLY` |
| _[n]_`>>`_f_ | 1 | open _f_ `O_CREAT \| O_APPEND \| O_WRONLY` |
| _[n]_`<>`_f_ | 0 | open _f_ `O_CREAT \| O_RDWR` |
| _[n]_`<&`_m_ | 0 | dup _n_ to _m_ (close if _m_ is `-`) |
| _[n]_`&>`_m_ | 1 | dup _n_ to _m_ (close if _m_ is `-`) |

http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_07

Did you know about `<>`?  That's something I only learned when I wrote
this workshop.  Note there's also `>|` which interacts with the
shell's `noclobber` option, which I haven't bothered to implement.

Note that `!`, which you added in stage 1, may appear only at the
start of a pipeline, and affects the return value of the whole
pipeline.

(`hush` uses the term *squirrel* to refer to an fd that's been
redirected where it wants to "squirrel away" the original fd, but I
initially thought it referred to `<&` and `&>`, which look like
squirrels; so now I'm calling those operators the squirrels.)

## Act 2

Let's also add process substitution and command substitution.

If you find `$(...)`, execute the contents of the parentheses as shell
input, capture its output in a string, and insert it in the argument
list.  (Feel free to also handle backtick syntax.)

If you find `<(...)`, open a pipe as before, but replace the
substitution with a reference to `/dev/fd/n`.  This isn't POSIX sh,
but it's really convenient.

## Epilogue

### CLOEXEC

You might have a bunch of files open in your shell, for example, files
for maintaining history or configuration.  Your children shouldn't
have to care about these files; file descriptors are a limited
resource and most people wouldn't appreciate having that limit
unnecessarily decreased just because you were lazy.

How can you prevent your children from inheriting fds you don't want
them to have?  Classically, people would loop over some number of fds,
closing them, which is time-consuming and error-prone.  A moderately
more recent idea is the `CLOEXEC` option on various fd-opening
syscalls, which tells the operating system to close this fd when
`execve` happens.  A lot of modern programming language libraries do
this by default, so you may already be safe, but it's worth thinking
about, particularly when writing a library that might open fds.

Recently, Linux [added an `fdmap` syscall] that could be used for
this.

Since I first wrote this, several languages have made `CLOEXEC` the
default, which means you'll have to disable it on the file descriptors
you actually want passed to the child.  For example [PEP-446], adopted
in Python 3.4, makes `CLOEXEC` the default for all these reasons, so
you'll need to `os.set_inheritable(fd, True)` explicitly on the file
descriptors you actually want passed to the child.

See Chris Siebenmann's [fork() and closing file descriptors] and
CERT's [FIO22-C] (close files before spawning processes).

You can use tools like `lsof` to debug problems with fd redirection.
Under Linux, you can also try running `ls -l /proc/self/fd` inside
your shell, with various redirections, and see what happens.

[fork() and closing file descriptors]: https://utcc.utoronto.ca/~cks/space/blog/unix/ForkFDsAndRaces
[FIO22-C]: https://www.securecoding.cert.org/confluence/display/c/FIO22-C.+Close+files+before+spawning+processes
[added an `fdmap` syscall]: https://lwn.net/Articles/734709/
[PEP-446]: https://peps.python.org/pep-0446/

### Builtins

So far your builtins have been simple and haven't interacted much
with commands.  What if we had a builtin in a pipeline?

If you don't run the builtin in a subshell, the pipeline may stall.
So you'll need to fork, but only when in a multi-command pipeline.

### posix_spawn

How do you perform the operations from this stage using posix_spawn,
which we looked at in stage 1?
