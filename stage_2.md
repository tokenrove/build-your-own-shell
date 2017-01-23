# Files and Pipes

## Dramatis Personae

`dup2(2)`, `pipe(2)`, `open(2)`, `close(2)`

## Prologue

POSIX specifies that, by default, the file descriptors 0, 1, and 2
correspond to standard input (stdin), output (stdout), and error
(stderr).  We'll use this fact to implement the Unix shell's greatest
feature: pipes and redirections.

First, we'll add a bit more syntax.  This is where a simple parsing
framework might start to be useful.

You'll need to separate your input by occurrances of `|`, and for each
command, find expressions of the form `n< path`, `n> path`, and `n>>
path`, where `n` is an optional integer.

If you'd like to handle quoting now, you might find it handy to look
at the [POSIX shell grammar] specification.  I don't think you
actually need to do this yet, though.  Just consider in your design
that splitting on whitespace won't be enough.

Note that you now may have to read multiple lines of input, if the
last token read is a pipe.  Take this opportunity to also support `\`
(backslash) as a line-continuation character.

If you're planning to use a parser generator, consider
[what Chet Ramey has to say] about bash and bison:

> One thing I've considered multiple times, but never done, is
> rewriting the bash parser using straight recursive-descent rather
> than using bison. I once thought I'd have to do this in order to
> make command substitution conform to Posix, but I was able to
> resolve that issue without changes that extensive. Were I starting
> bash from scratch, I probably would have written a parser by
> hand. It certainly would have made some things easier.

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
| _[n]_`>`_f_ | 1 | open _f_ `O_CREAT|O_TRUNC|O_WRONLY` |
| _[n]_`>>`_f_ | 1 | open _f_ `O_CREAT|O_APPEND|O_WRONLY` |
| _[n]_`<>`_f_ | 0 | open _f_ `O_CREAT|O_RDWR` |
| _[n]_`<&`_m_ | 0 | dup _n_ to _m_ (close if _m_ is `-`) |
| _[n]_`&>`_m_ | 1 | dup _n_ to _m_ (close if _m_ is `-`) |

http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_07

## Act 2

Let's also add process substitution.  If you find `<(...)`, open a
pipe as before, but replace the substitution with a reference to
`/dev/fd/n`.

Although it's not related, now that you're handling balanced
parenthesis syntax, let's add command substitution.  If you find
`$(...)`, execute the program, capture its output in a string, and
insert it in the argument list.  (Feel free to also handle backtick
syntax.)

## Epilogue

### CLOEXEC

(why it's important, and why you can't use it here)

How can you prevent your children from inheriting fds you don't want
them to have?

You can use tools like `lsof` to debug problems with fd redirection.
Under Linux, you can also try running `ls -l /proc/self/fd` inside
your shell, with various redirections, and see what happens.

### Builtins

So far your builtins have been simple and haven't interacted much
with commands.  What if we had a builtin in a pipeline?

If you don't run the builtin in a subshell, the pipeline may stall.

### posix_spawn

How do you perform the operations from this stage using posix_spawn,
which we looked at in stage 1?
