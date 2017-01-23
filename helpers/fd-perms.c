#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* Tries to determine the permissions associated with an fd (indicated
 * numerically by argument) by reading and writing to it. */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    if (2 != argc) abort();
    int fd = atoi(argv[1]);
    /* So, reads and writes of 0 bytes may or may not work on
     * different systems and objects, but so far I've been lucky. */
    bool readable = 0 == read(fd, NULL, 0);
    bool writable = 0 == write(fd, NULL, 0);
    puts(readable && writable ? "rw" : readable ? "r" : "w");
    return 0;
}
