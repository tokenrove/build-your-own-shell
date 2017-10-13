#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* Exec our args, and kill it after n seconds.  timeout(1) isn't
 * everywhere yet. */

#include <errno.h>
#include <signal.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


static pid_t pid;


static int really_waitpid(void)
{
    int status;
    pid_t rv;
    do { rv = waitpid(pid, &status, 0); } while (-1 == rv && EINTR == errno);
    if (rv != pid) abort();
    return WEXITSTATUS(status);
}


static void kill_em_all(int _)
{
    (void)_;
    kill(pid, SIGTERM);
    exit(1);
}


int main(int argc, char **argv, char **envp)
{
    struct sigaction action = {
        .sa_handler = kill_em_all,
    };
    if (argc < 3) abort();
    sigaction(SIGALRM, &action, NULL);
    if (posix_spawn(&pid, argv[2], NULL, NULL, argv+2, envp)) abort();
    alarm(atoi(argv[1]));
    exit(really_waitpid());
}
