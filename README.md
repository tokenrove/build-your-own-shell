> All the broken  
> Too many broken  
> Shells  
> In our shellmounds  
 — [Grayceon, Shellmounds](https://grayceon.bandcamp.com/track/shellmounds)

# Build Your Own Shell

This is the material for a series of workshops I ran at my workplace
on how to write a Unix shell.

The focus is slightly more on building an interactive shell than a
scripting-oriented shell, only because I think this is more
gratifying, even if it's less useful.

Be warned that some of the suggestions and discussion make opinionated
choices without discussing equally-valid alternatives.

This is a work in progress and there may remain many infelicities.
Patches Thoughtfully Considered.  Feel free to report issues via
[Github](https://github.com/tokenrove/build-your-own-shell/issues).

## Why write your own shell?

The shell is at the heart of Unix.  It's the glue that makes all the
little Unix tools work together so well.  Understanding it sheds light
on many of Unix's important ideas, and writing our own is the best
path to that understanding.

This workshop has three goals:

 - to give you a better understanding of how Unix processes work;
   - this will make you better at designing and understanding software
     that runs on Unix;
 - to clarify some common misunderstandings of POSIX shells;
   - this will make you more effective at using and scripting
     ubiquitous shells like bash;
 - to help you build a working implementation of a shell you can be
   excited about working on.
   - there are endless personal customizations you can make to your
     own shell, and can help you think about how you interact with
     your computer and how it might be different.

(some of this rationale is expanded on in my blog post, [Building
shells with a grain of salt])

[Building shells with a grain of salt]: https://www.cipht.net/2017/10/17/build-your-own-shell.html

## How to use this repository

I've tried to break this up into progressive stages that cover mostly
orthogonal topics.  Each stage contains a description of the
facilities that will be discussed, a list of manpages to consult, and
a set of tests.  I've tried to also hint at some functionality that is
fun but not necessary for the tests to pass.

In the root of this repository, there is a script called `validate`;
you can run all the tests against your shell-in-progress by specifying
the path to your shell's executable, like this:

``` shell
$ ./validate ../mysh/mysh
```

It should tell you what stage you need to implement next.

To run the tests, you will need [`expect`], which is usually in a
package called `expect`, and a C compiler.  The way the tests are
implemented is less robust than one might hope, but should suffice for
our pedagogical goals.

The tests assume you will be implementing a vanilla Bourne-flavored
shell with some ksh influences.  Feel free to experiment with
alternate syntax, but if so, you may need to adjust the tests.  Except
where specifically noted, `bash` (and `ksh`) should pass all the
tests, so you can "test the tests" that way.  (Try `./validate
/bin/bash`; likewise, `cat` should fail all the tests.  Originally, I
targeted plain `/bin/sh`, but I decided the material in stage 5 was
too important.)

[`prove`]: http://perldoc.perl.org/prove.html
[`expect`]: http://wiki.tcl.tk/201

# Stages

## 1: [fork/exec/wait](stage_1.md)

In which we discuss the basics of Unix processes, write the simplest
possible shell, and then lay the foundations for the rest of the
steps.

## 2: [files and pipes](stage_2.md)

In which we add pipes and fd redirection to our shell.

## 3: [job control and signals](stage_3.md)

In which we discuss signals and add support for ever-helpful chords
like `^C`, `^\`, and `^Z`.

## 4: [quoting and expansion](stage_4.md)

In which we discuss environments, variables, globbing, and other
oft-misunderstood concepts of the shell.

## 5: [interactivity](stage_5.md)

In which we apply some polish to our shell to make it usable for
interactive work.

## &: [where to go next](next-steps.md)

In which I prompt you to go further.

# Shells written from this workshop

I'll link to some of the shells that were written as a result of this
workshop here shortly, including a couple I wrote to serve as examples
of different approaches.

# Supplementary Material

## Tools

 - The [shtepper] is a great resource for understanding shell
   execution.  You can input an expression and see in excruciating
   detail how it should be evaluated.

[shtepper](http://shell.cs.pomona.edu/shtepper)

## Documents

 - [Advanced Programming in the Unix Environment] by Stevens covers
   all this stuff and is a must-read.  I call this *APUE* throughout
   this tutorial.
 - Chet Ramey describes [the Bourne-Again Shell] in [the Architecture
   of Open Source Applications]; this is probably the best thing to
   read to understand the structure of a real shell.
 - Michael Kerrisk's [the Linux Programming Interface], though fairly
   Linux-specific, has some great coverage of many of the topics we'll
   touch on.  I call this *LPI* throughout this tutorial.
 - [Unix system programming in OCaml] shows the development of a simple shell.
 - [Advanced Unix Programming] by Rochkind; chapter 5 has a simple shell.
 - the [tour of the Almquist shell] is outdated but may help you find
   where some things are implemented in `dash` and other `ash`
   descendants.

### Other Tutorials

I wrote this workshop partially because I felt other tutorials don't
go far enough, but all of these are worth reading, especially if
you're having trouble with a stage they cover:

 - Stephen Brennan's [Write a Shell in C] is a more detailed look at
   what is [stage 1](stage_1.md) here.
 - Jesse Storimer's [A Unix Shell in Ruby] gets as far as pipes;
 - Kamal Marhubi's [Let's Build a Shell] also goes about that far;
 - glibc's [Implementing a Job Control Shell] shows specifically how
   to implement job control;
 - Nelson Elhage's [Signalling and Job Control] covers some
   of [stage 3](stage_3.md)'s material.

### References

 - the [POSIX standard] explains the expectations for the shell and
   its utilities in reasonable detail.
 - there are [POSIX conformance test suites] but they don't seem to be
   available in convenient, non-restricted forms.
 - [yash's posix-shell-tests] are only runnable with yash, but the
   tests themselves are full of useful ideas.

[A Unix Shell in Ruby]: http://www.jstorimer.com/blogs/workingwithcode/7766107-a-unix-shell-in-ruby
[Advanced Programming in the Unix Environment]: http://www.apuebook.com/
[Advanced Unix Programming]: http://basepath.com/aup/
[Implementing a Job Control Shell]: https://www.gnu.org/software/libc/manual/html_node/Implementing-a-Shell.html
[Let's Build a Shell]: https://github.com/kamalmarhubi/shell-workshop
[POSIX standard]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
[Signalling and Job Control]: https://blog.nelhage.com/2010/01/a-brief-introduction-to-termios-signaling-and-job-control/
[the Architecture of Open Source Applications]: http://www.aosabook.org/en/index.html
[the Bourne-Again Shell]: http://www.aosabook.org/en/bash.html
[the Linux Programming Interface]: http://man7.org/tlpi/index.html
[tour of the Almquist shell]: http://git.kernel.org/cgit/utils/dash/dash.git/tree/src/TOUR
[Unix system programming in OCaml]: https://ocaml.github.io/ocamlunix/
[Write a Shell in C]: https://brennan.io/2015/01/16/write-a-shell-in-c/
[POSIX conformance test suites]: https://www.opengroup.org/testing/testsuites/vscpcts2003.htm
[yash's posix-shell-tests]: https://github.com/posix-shell-tests/posix-shell-tests

## Shells to Examine

 - [busybox]: C; contains both ash and hush, and test suites.
 - [mksh]: C; non-interactive tests.
 - [rc]: C; fairly minimal.
 - [zsh]: C; extremely maximal.
 - [bash](https://savannah.gnu.org/git/?group=bash): C.
 - [fish]: C++11; has expect-based interactive tests.
 - [Thompson shell]: C; the original Unix shell; very minimal.
 - [scsh]: Scheme and C; intended for scripting.
 - [cash]: OCaml; based on scsh.
 - [eshell]: Emacs Lisp.
 - [oil]: Python and C++; has an extensive test suite.
 - [xonsh](http://xon.sh/): Python.
 - [oh](https://github.com/michaelmacinnis/oh): Go.
 - [yash-rs](https://github.com/magicant/yash-rs): Rust.

[busybox]: https://git.busybox.net/busybox/tree/shell
[cash]: https://github.com/ShamoX/cash
[eshell]: https://github.com/emacs-mirror/emacs/tree/master/lisp/eshell
[fish]: https://github.com/fish-shell/fish-shell
[mksh]: https://github.com/MirBSD/mksh
[oil]: https://github.com/oilshell/oil
[rc]: https://github.com/rakitzis/rc
[scsh]: https://github.com/scheme/scsh
[Thompson shell]: https://github.com/dspinellis/unix-history-repo/blob/Research-V5-Snapshot-Development/usr/source/s2/sh.c
[zsh]: https://github.com/zsh-users/zsh

## Links to Resources by Language

Although there is an elegant relationship between C and Unix which
makes it attractive to write a shell in the former, to minimize
frustration I suggest trying a higher-level language first.  Ideally
the language will have good support for:

- making POSIX syscalls
- string manipulation
- hash tables

Languages that provide a lot of their own infrastructure with regards
signals or threads may be much more difficult to use.

### C++

http://basepath.com/aup/ex/group__Ux.html

### Common Lisp

The most convenient library would be [iolib], which you can get
through [Quicklisp].  You'll need to install `libfixposix` first.
There's also [sb-posix] in `sbcl` for the daring.

[iolib]: https://github.com/sionescu/iolib
[Quicklisp]: https://www.quicklisp.org/
[sb-posix]: http://www.sbcl.org/manual/#sb_002dposix

### Haskell

 - use [the unix package](https://hackage.haskell.org/package/unix)
 - [Hell] might be a starting point

[Hell]: https://github.com/chrisdone/hell/

### Java / JVM-based languages

You will probably run into issues related to the JVM, particularly
with signals and forking, but as a starting point, you could do worse
than loading libc with JNA.

There's also [jtux](http://basepath.com/aup/jtux/index.htm).

### Lua

There are a variety of approaches, but [ljsyscall] looks promising.
[luaposix] might be sufficient.

[ljsyscall]: https://github.com/justincormack/ljsyscall
[luaposix]: https://github.com/luaposix/luaposix

### OCaml

 - [Unix module](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html)
 - [lambda-term](https://github.com/diml/lambda-term)
 - [parsing with OCamllex and menhir](https://realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html)

See also [Unix system programming in OCaml], [cash].

### perl

See `perlfunc(3perl)`; all the functions we want are at hand, usually
with the same name.

### Python

Although Python provides higher-level abstractions like
[`subprocess`], for the purposes of this workshop you probably want to
use the functions in [`os`].

Please note an important gotcha for stage 2!  Since [Python 3.4], fds
have defaulted to non-inheritable, which means you'll need to
explicitly `os.set_inheritable(fd, True)` any file descriptor you
intend to pass down to a child.

[`os`]: https://docs.python.org/3/library/os.html
[`subprocess`]: https://docs.python.org/3/library/subprocess.html
[Python 3.4]: https://peps.python.org/pep-0446/

### Racket

The implementation seems a little too heavy to do this conveniently,
but see the Scheme section below for alternatives.

### Ruby

`Process` has most of what you need.  You can use `Shellwords` but you
decide if it's cheating or not.

### Rust

Although we use few enough calls that you could just create bindings
directly, either
[to libc with the FFI](https://doc.rust-lang.org/book/ffi.html) or by
[directly making syscalls](https://crates.io/crates/syscall), for just
getting something working, the [nix-rust] library should provide all
the necessary facilities.

[nix-rust]: https://github.com/nix-rust/nix

### Scheme

Guile already has all the calls you need; see
[the POSIX section of the Guile manual].  Another approach would be to
use something like [Chibi Scheme] with bindings to libc calls.

[Chibi Scheme]: https://github.com/ashinn/chibi-scheme
[the POSIX section of the Guile manual]: https://www.gnu.org/software/guile/manual/html_node/POSIX.html#POSIX

### Tcl

Although core Tcl doesn't provide what's necessary, `expect` probably
does.  For example, Tcl doesn't have a way to `exec`, but expect
provides `overlay` to do this.
