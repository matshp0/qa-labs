/* LD_PRELOAD shim: lets dnsmasq run in an unprivileged user namespace where setgroups() is denied */
#include <stddef.h>
int setgroups(size_t n, const void *l) { return 0; }
int setgid(unsigned g) { return 0; }
int setuid(unsigned u) { return 0; }
