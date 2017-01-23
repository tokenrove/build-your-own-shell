# Code common to all tests

proc ok {string body} {
    if {![[proc {} {} $body]]} { send_user "not " }
    puts "ok - $string"
}

proc plan {n} {
    puts "1..$n"
}

proc expect_prompt {} {
    expect -exact "\$ " {return yes} default {return no}
}

proc send_echoed_command {cmd} {
    send "$cmd\r"
    expect -exact "$cmd\r\n"
}


log_user 0
if {0 == [llength $argv]} {
    send_user "Bail out!  Supply the path to your shell as the sole argument.\n"
    exit 1
}
spawn [lindex $argv 0]
