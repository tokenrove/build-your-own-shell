#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* List what fds were open when we were exec'd. */

#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>

int main(void)
{
    struct stat sb;

    for (long i = 0; i < sysconf(_SC_OPEN_MAX); ++i) {
        if (fstat(i, &sb)) continue;
        printf("%ld\n", i);
    }
    return 0;
}
