#include "primecount.hpp"
#include <stdio.h>

extern "C"
{
  int64_t pi(int64_t x) {
    printf("Hello from cprimecount\n");
    return primecount::pi(x);
  }

  int64_t pi_deleglise_rivat(int64_t x) {
    printf("Hello from delegise cprimecount\n");
    return primecount::pi_deleglise_rivat(x);
  }

  

}
