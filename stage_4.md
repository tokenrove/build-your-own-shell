# Environments, Variables, and Expansion

## Ingredients

 - a map type;
 - [`getpwnam(3)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/getpwnam.html);
 - [`glob(3)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/glob.html);
 - some way to get at the environment; this varies by language.

See for example
[`getenv(3)`](http://pubs.opengroup.org/onlinepubs/9699919799/functions/getenv.html).

## Instructions

We'll implement the basics of environments, variables, and expansions,
because they're useful and good to understand.  We will, however,
greatly simplify some things, because I don't think they matter too
much for an interactive shell.  For example, shell purists will be
furious that we don't deal with `IFS`.  Sorry.

### Environment variables

Extend your input parser so that, if a command starts with any words
containing the `=` character, these are treated as variable
assignments, and the actual command starts with the first word not
containing an `=` (and there might only be variable assignments on a
line, with no command).

So you're looking to recognize something like:
```
foo=baz bar=quux ls
```

This runs `ls` with an environment where `baz` is assigned to `foo`
(that is, `getenv("foo")` returns `"baz"`, or `echo $foo` echos `baz`)
and `quux` is assigned to `bar`.  Note that the current shell's
environment is not modified by this.

Meanwhile,
```
foo=baz bar=quux
```
without a command will set these variables in the local environment.

A key thing here is how exported variables work.  There is a lot of
misconception around when `export` needs to be called in shells.  Once
a variable has been exported, it remains exported.  Exported variables
will be passed on to child processes, while unexported variables are
only visible in the current shell.

let's look at how various libcs implement `getenv` and friends:
FreeBSD, musl, glibc

From [hush.c:717](https://git.busybox.net/busybox/tree/shell/hush.c#n717):

```c
/* On program start, environ points to initial environment.
 * putenv adds new pointers into it, unsetenv removes them.
 * Neither of these (de)allocates the strings.
 * setenv allocates new strings in malloc space and does putenv,
 * and thus setenv is unusable (leaky) for shell's purposes */
#define setenv(...) setenv_is_leaky_dont_use()
```

You might enjoy ["the setenv fiasco"].

### Special parameters

There are some special "variables" that can be expanded with `$`,
which the standard calls *special parameters*.  Most of them are
primarily useful for scripting, so we won't implement them.

You should implement `$?`, which expands to the exit status of the
last pipeline executed, `$$`, which expands to the PID of the current
shell, and `$!` which expands to the PID of the most recent background
command.

See [Special Parameters] in the standard for the gory details.

[Special Parameters]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_05_02


### Quoting

Quoting in shell is notoriously hard, and the edge cases are still a
subject of active debate.  Don't try for perfect; the important thing
is to really get an understanding of the difference between single
(`'`) and double (`"`) quotes; to understand why `"foo$(echo
"$bar")baz"` is safe and `"foo"$bar"baz"` isn't.

I think the most common misconception among casual users of the shell
for scripting is that quotes form some kind of special data type;
implementing quoting and realizing it's all just strings will greatly
improve any shell scripts you write in the future.

See 2.2 [Quoting] in the standard.

[Quoting]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_02

### Heredocs

```shell
sudo -u postgres psql <<EOF
CREATE DATABASE $DATABASE_NAME;
CREATE USER $DATABASE_USER WITH PASSWORD '$DATABASE_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;
EOF
```

When you have something that needs some multi-line file input, but you
want to keep it local to the code that uses it, heredocs are your
friend.  However, they are the enemy of your lexer and parser, as they
introduce some significant context-sensitivity.  While lexing and
parsing, if you find `<<word` or `n<<word` (where `n` is an fd number,
and `word` is any valid shell word), then read the lines that follow
(*not* counting the continuation of the line the heredoc appeared on
with `\\`) into memory, until you find a line that contains only
`word`, then execute the pipeline with that fd (`0` if none is
specified) redirected to something which will yield the contents of
the heredoc, with any variable references (`$foo`) expanded.

How to deal with the temporary fd?  Although `bash` actually creates a
temporary file, I prefer the simpler approach of `hush`: create a
pipe, and fork a child which writes the heredoc contents into that
pipe.

There can actually be multiple heredocs on a line, but if you only
want to implement one for now, I think that's ok.

See [Heredocs], [How to Parse Here Documents].

[Heredocs]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_07_04
[How to Parse Here Documents]: http://www.oilshell.org/blog/2016/10/17.html

### Globbing

See http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06

We'll add `*` and `?`.  `glob(3)` is kind of a cheap way to do this;
the key thing is you need to be able to expand one word (like `foo*`)
into zero or more words, before actually running the pipeline it's in.

Incidentally, `glob` was originally a standalone program; you might
find it [interesting to
read](https://github.com/dspinellis/unix-history-repo/blob/38371171d1ed457a43a9c8e7f2df5d596916209d/usr/source/s1/glob.c#L132-L137).

See [Pathname Expansion] and [Pattern Matching Notation] in the
standard.

[Pathname Expansion]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_06
[Pattern Matching Notation]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_13

**Bonus:** I didn't ask you to add `[]` but it's part of the standard.
Some other globbing I find useful you might consider implementing:
`**`, and `(/)`, `(.)`, `(*)` from zsh are really useful.  `{}` from
`ksh` is also really useful.

### Tilde expansion

`~` on its own or followed by a slash should expand to the value of
the `HOME` environment variable (so `~/foo` becomes `/home/me/foo`).
`~user` should expand to the home directory for that user, as given
from `getpwnam(3)`.

See [Tilde Expansion].

[Tilde Expansion]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_01

## Extras

Make the prompt configurable with the `PS1` environment variable.  You
can go wild with how this is specified.  Consider an efficient way of
presenting the current git status and branch as part of the prompt.

The environment variable `PS2` should control the continuation prompt
(the one you print after each line that ends in `\\`).

["the setenv fiasco"]: http://www.club.cc.cmu.edu/~cmccabe/blog_the_setenv_fiasco.html
