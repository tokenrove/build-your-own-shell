#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* Exec our args and print the exit status.  We originally used a
 * shell script for this but I was worried there could be some
 * quoting/interpretation issues and figured it would be easier to
 * guarantee the behavior of this program. */

#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

static int really_waitpid(pid_t pid)
{
    int status;
    pid_t rv;
    do { rv = waitpid(pid, &status, 0); } while (-1 == rv && EINTR == errno);
    if (rv != pid) abort();
    return status;
}


int main(int argc, char **argv, char **envp)
{
    pid_t pid;
    if (argc < 2) abort();
    if (posix_spawn(&pid, argv[1], NULL, NULL, argv+1, envp)) abort();
    printf("%d\n", really_waitpid(pid));
    return 0;
}
