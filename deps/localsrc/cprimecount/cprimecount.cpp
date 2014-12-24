#include "primecount.hpp"

extern "C"
{
  int64_t pi(int64_t x) {
    return primecount::pi(x);
  }

}
