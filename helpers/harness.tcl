#!/usr/bin/env expect
#
# This script runs the specified shell in a temporary directory, and
# executes the .t test specifications.
#
# The implementation of getting expected values back from the shell is
# not terribly robust, but was a lot simpler, as a first stab, to fit
# into expect's way of doing things.  I thought about either having a
# ptrace'ing wrapper around the shell that watches for forks and so
# on, or more wrapper commands in the spirit of those already present,
# but maybe once someone complains.
#
# Even a ptrace approach that spits out child exit statuses can get
# confused by things like prompts that execute commands.  So maybe
# we'd better keep it simple.

# symbols:
# ⏎ ⇒ newline
# ☠ ⇒ shell itself exits, with code
# → ⇒ user input
# ← ⇒ response on stdout
# ↵ ⇒ response on stdout delimited by a CR or LF
# ≠ ⇒ anything but this on stdout (at least one line)
# ✓ ⇒ expect zero exit status of previous command (not implemented)
# ✗ ⇒ expect nonzero exit status of previous command (not implemented)
# ⌛ ⇒ wait a little extra (0.5 seconds)

proc expand {s} {
    string map {
        ⏎ \r
        ⇑ \x1b\x5bA
        \\n \r\n
        ^C \x03
        ^D \x04
        ^I \x09
        ^R \x12
        ^Z \x1a
        ^\\ \x1c
    } $s
}

proc 1+ {x} { expr 1 + $x }
proc rest-of {s} {
    set i [1+ [string first { } $s]]
    if {-1 == $i} { return {} }
    string range $s $i end
}

proc cleanup {} {
    global temp_dir
    file delete -force $temp_dir
}

# This assumes this script is in helpers/
set script_path [file dirname [file normalize [info script]]]

proc setup_execution_environment {} {
    global script_path temp_dir
    set temp_dir [exec mktemp -q -d -t "shell-workshop.XXXXXX"]
    exit -onexit cleanup
    cd $temp_dir
    file link -symbolic helpers $script_path
    # sanity check
    if {![file exists ./helpers/echo-signal]} {
        error {we didn't find files we thought would exist;
            make sure harness.tcl is in the helpers directory}
    }
    set ::env(PATH) [join [list /bin /usr/bin [join [list [pwd] helpers] /]] :]
    set ::env(KNOWN_VARIABLE) {reindeer flotilla}
}

proc wait_for_exit {} {
    # seems to be needed for buffering issues on BSD
    expect {
        eof {}
        timeout {}
    }
    foreach {pid spawn_id is_os_error code} [wait] break
    if {0 == $is_os_error} { return $code }
    not_ok
}

if {2 != [llength $argv]} {
    error "Arguments are the test description file, and the path to your shell."
}

set emit_tap 0
set test_path [lindex $argv 0]
set shell [lindex $argv 1]
set test_file [open $test_path]
fconfigure $test_file -encoding utf-8

# read through file and count tests
set n_tests 0
while {![eof $test_file]} {
    switch -re [string index [gets $test_file] 0] {
        ←|↵|≠|✓|✗|☠ {incr n_tests}
        default {}
    }
}
seek $test_file 0 start

log_user 0
setup_execution_environment
if [catch {spawn $shell} err] {error $err}
# waiting a little extra for first prompt can help.  if your shell
# emits no prompt, that's not very friendly.
set timeout 3
expect -re .+
set timeout 2

set line_num 0
set test_num 1
proc ok {} {
    global test_num test_path line_num emit_tap
    if {1 == $emit_tap} {puts "ok $test_num # $test_path:$line_num"}
    incr test_num
}
proc not_ok {} {
    global test_num test_path line_num command emit_tap
    if {0 == $emit_tap} {
        puts "\x1b\[91m$command\x1b\[31m"
        puts "failed at $test_path:$line_num\x1b\[m"
    } else {
        puts "not ok $test_num # $test_path:$line_num"
    }
    incr test_num
    exit $test_num
}
proc is {x} { uplevel 1 [list if $x {ok} {not_ok}]}

proc re_quote {s} {
    string map {
        \\ \\\\
        ^ \\^
        \$ \\\$
        \[ \\\[
        \( \\\(
        . \\.
        + \\+
        * \\*
        ? \\?
        \{ \\\{
    } $s
}

proc expect_line {line} {
    # NB: this is fairly unreliable, and we should have some lint
    # where we reject tests whose expected output would match the tail
    # of their input.  There doesn't seem to be a better way to deal
    # with the output and timing differences between shells, short of
    # going full ptrace as mentioned previously.
    set rv [expect {
        -re $line {return 1}
        default {return 0}
    }]
    expect *
    return $rv
}

# The timing of sending a line can be tricky.  Shells are usually
# sending their prompts to stderr, and so output to stdout can race
# with that.  We used to use send -s (send_slow) here, but in practice
# it seems unnecessary; what does seem necessary, is giving the shell
# a little bit of time before we look at the output or send the next
# line.
proc careful_send {m} {
    if {[catch {send -- $m} err]} { error $err }
    sleep 0.01
}

if {1 == $emit_tap} {puts "1..$n_tests"}
while {![eof $test_file]} {
    gets $test_file command
    incr line_num
    if {0 == [string length [string trim $command]]} { continue }
    set line [expand [rest-of $command]]
    switch [string index $command 0] {
        → {expect *; careful_send $line}
        ↵ {is {1 == [expect_line "\[\r\n][re_quote $line]"]}}
        ← {is {1 == [expect_line [re_quote $line]]}}
        ≠ {is {0 == [expect_line "\[\r\n][re_quote $line]"]}}
        ✓ {error "sorry we decided not to do this $line_num"}
        ✗ {error "sorry we decided not to do this $line_num"}
        ⌛ {sleep 0.2}
        ☠ {
            is {$line eq [wait_for_exit]}
            if {$test_num <= $n_tests} {
                error "☠ must always be the last test"
            }
            exit 0;             # not_ok will have died by now
        }
        \# {}
        default {error "unexpected command $command"}
    }
    if {0 == $emit_tap} {puts $command}
}

# Calling close causes zsh to exit unhappily, so we send ^D instead.
sleep 0.1; send "\x04"
if {0 != [wait_for_exit]} {error "shell didn't exit cleanly"}
