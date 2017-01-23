#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* catch signal provided as an argument and echo it (once); it would
 * be nicer to use a signalfd and poll it, but it's less portable. */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void echo(int n)
{
    printf("%d\n", n);  /* safe-ish because we don't do anything else.  hah. */
}

int main(int argc, char **argv)
{
    struct sigaction action = { .sa_handler = echo };
    if (2 != argc) abort();
    int sig = atoi(argv[1]);
    sigaction(sig, &action, NULL);
    pause();
    return 0;
}
