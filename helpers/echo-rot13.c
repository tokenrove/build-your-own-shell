#if 0
set -x "$(dirname $0)/$(basename $0 .c)"
exec ${CC:-cc} ${CFLAGS:--Wall -Wextra -g} $0 -o $1
#endif

/* Echo our arguments, rot13'd. */

#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

static void rot13(char *s)
{
    while (*s) {
        char c = *s|32;
        if (c >= 'a' && c <= 'm') *s += 13;
        else if (c >= 'n' && c <= 'z') *s -= 13;
        ++s;
    }
}

int main(int argc, char **argv)
{
    for (int i = 1; i < argc; ++i)
        rot13(argv[i]);
    if (argc > 1) printf("%s", argv[1]);
    for (int i = 2; i < argc; ++i)
        printf(" %s", argv[i]);
    puts("");
    return 0;
}
