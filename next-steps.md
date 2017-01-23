# What next?

Congratulations for making it through the workshop.  Most people, if
they ever undertake a toy shell, stop around stage 1 or 2.  You should
at this point have a shell you could actually use as an interactive
shell for a while.  (Estimated length of time before it becomes too
annoying, in my experience: about one month.)

I think there is a lot to be done with shells in general.  I'll list
here some starting points you might find interesting.

## security: capabilities / pledge

The [shill] project has some interesting ideas.  ksh in openbsd
[has a `pledge` builtin].  Can you make your shell scripts safer?
What about your interactive shell sessions?  Or the dreaded `curl |
sh`?

[has a `pledge` builtin]: https://github.com/netzbasis/openbsd-src/compare/master...hf-ksh_builtin_pledge
[shill]: http://shill.seas.harvard.edu/

## features from other programming languages

 - advisory safety through annotation of commands with types
   describing their input or output

 - logic or constraint-based mechanisms -- for example, instead of
   globbing with wildcards, why not file-name unification?

 - example-based [program synthesis]

[program synthesis]: http://research.microsoft.com/en-us/um/people/sumitg/pubs/synthesis.html

## interactive ergonomics

 - autodetect completions from manpage or `--help` output

 - perhaps one could even come up with a clever unobtrusive manpage
   excerpt display not unlike popup help in many IDEs

 - real-time visualization of what will happen when a pipeline is
   executed

 - visualization of CPU/IO usage of elements of running pipeline

## integration with commonly-used software

 - if your shell is in a VM-based language like Java or Erlang, you
   could speed up loading of other code in the same language, like the
   Android `zygote` concept

 - you probably have many `git`-related tweaks to your current shell;
   could these be faster or tighter if you linked to `libgit2`
   directly?

 - what about integration with `screen` or `tmux`?

 - what if you extended pipe syntax to conveniently support arbitrary
   sockets or ssh connections?

 - GNU parallel is a very popular tool; is it possible to provide its
   major features directly in a shell?

## alternative uses of the shell

 - it's often been noted that `make` and `cron`, maybe with a dash of
   `inotify`, could have better integration with the shell, or be
   their own combined tool entirely.

 - could you build a shell fuzzing or testing tool using what you have
   so far?
