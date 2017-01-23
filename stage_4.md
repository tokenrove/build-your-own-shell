# Environments, Variables, and Expansion

## Ingredients

a map type

see also `setenv(3)`, `getenv(3)`

## Instructions

This is the point at which you may want to use a generated parser or
parser combinators rather than dealing with ad hoc parsing of user
input.

See http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_23

Each word containing the `=` character on the command line

`if`



let's look at how various libcs implement `getenv` and friends:
FreeBSD, musl, glibc

You might enjoy ["the setenv fiasco"].


# Globbing

See http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06

We'll add `~`, `*`, `?`


## Extras

Make the prompt configurable.  You can go wild with how this is
specified.  Consider an efficient way of presenting the current git
status and branch as part of the prompt.

["the setenv fiasco"]: http://www.club.cc.cmu.edu/~cmccabe/blog_the_setenv_fiasco.html
