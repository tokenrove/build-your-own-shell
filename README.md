# Write Your Own Shell

This is the material for a series of workshops I'm planning to run at
my workplace on how to write a Unix shell.

The focus is slightly more on building an interactive shell than a
scripting-oriented shell, only because I think this is more
gratifying, even if it's less useful.

Be warned that some of the suggestions and discussion make opinionated
choices without discussing equally-valid alternatives.

## Why write your own shell?

The shell is at the heart of Unix.  It's the glue that makes all the
little Unix tools work together so well. Understanding it allows us to
understand many important ideas about Unix, and writing our own is the
best way to understand it.

## How to use this repository

I've tried to break this up into progressive stages that cover mostly
orthogonal topics.  Each stage contains a description of the
facilities that will be discussed, a list of manpages to consult, and
a set of tests.

The tests assume you will be implementing a vanilla Bourne-flavored
shell.  Feel free to experiment with alternate syntax, but if so,
you'll need to adjust the tests.

# Stages

## [fork/exec/wait](stage_1)

In which we discuss the basics of Unix processes and write the
simplest possible shell.

## [files and pipes](stage_2)

In which we add pipes and fd redirection to our shell.

## [interactivity](stage_3)

In which we take a detour into PTYs and termcaps to provide
rudimentary interactive features for our shell.

## [job control and signals](stage_4)

In which we discuss signals and add support for ever-helpful chords
like `^C`, `^\`, and `^Z`.

## [environments, variables, and scripting](stage_5)

In which we make our shell more customizable and start adding
scripting constructs.

## [completion and globbing](stage_6)

In which we add a few more features that tend to make the shell
experience pleasant.

# Supplementary Material

## Documents

 - the [POSIX standard]
 - [Unix system programming in OCaml] shows the development of a simple shell
 - Advanced Unix Programming by Rochkind
 - APUE by Stevens
 - the [tour of the Almquist shell] is outdated but may help you find
   where some things are implemented in `dash` and other `ash`
   descendants

[Unix system programming in OCaml]: https://ocaml.github.io/ocamlunix/
[POSIX standard]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
[tour of the Almquist shell]: http://git.kernel.org/cgit/utils/dash/dash.git/tree/src/TOUR

## Shells to Examine

 - [busybox]: C; contains both ash and hush, and test suites.
 - [mksh]: C; non-interactive tests.
 - [rc]: C.
 - [zsh]: C.
 - [fish]: C++11; has expect-based interactive tests.
 - [Thompson shell]: C; the original Unix shell; very minimal.

[busybox]: https://git.busybox.net/busybox/tree/shell
[fish]: https://github.com/fish-shell/fish-shell
[mksh]: https://github.com/MirBSD/mksh
[rc]: https://github.com/rakitzis/rc
[Thompson shell]: https://github.com/dspinellis/unix-history-repo/blob/Research-V5-Snapshot-Development/usr/source/s2/sh.c
[zsh]: https://github.com/zsh-users/zsh

## Links to Resources by Language

Although there is an elegant relationship between C and Unix which
makes it attractive to write a shell in the former, to minimize
frustration I suggest trying a higher-level language first.  Ideally
the language will have good support for:

- string manipulation
- hash tables
- making POSIX syscalls

### OCaml

 - [Unix module](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html)
 - [lambda-term](https://github.com/diml/lambda-term)
 - [parsing with OCamllex and menhir](https://realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html)

See also [Unix system programming in OCaml], [cash](https://github.com/ShamoX/cash).
