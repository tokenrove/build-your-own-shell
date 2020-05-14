#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* catch signal provided as an argument and echo it (once); it would
 * be nicer to use a signalfd and poll it, but it's less portable. */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static sig_atomic_t got;

static int int_of_signal_name(char *name)
{
    if (!strcmp(name, "INT")) return SIGINT;
    if (!strcmp(name, "TSTP")) return SIGTSTP;
    if (!strcmp(name, "CONT")) return SIGCONT;
    if (!strcmp(name, "TERM")) return SIGTERM;
    abort();
}

static void handler(int n) { got = n; }

int main(int argc, char **argv)
{
    struct sigaction action = { .sa_handler = handler };
    if (2 != argc) abort();
    int sig = int_of_signal_name(argv[1]);
    sigaction(sig, &action, NULL);
    puts("ready");
    do { pause(); } while (sig != got);
    puts(argv[1]);
    return 0;
}
