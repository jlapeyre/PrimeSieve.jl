#include "primecount.hpp"
#include "primesieve.hpp"
#include <stdio.h>
#include <signal.h>

/*
namespace primecount {
  typedef __int128_t int128_t;

  int128_t pi_deleglise_rivat(int128_t x, int threads)
  {
  // use 64-bit if possible

    if (x <= numeric_limits<int64_t>::max())
      return pi_deleglise_rivat((int64_t) x, threads);
    
    if (threads <= 1)
      return pi_deleglise_rivat3(x);
    else
      return pi_deleglise_rivat_parallel3(x, threads);
  }
}
*/

namespace primesieve {
  uint64_t popcount(const uint64_t* array, uint64_t size);
}

extern "C"
{


  /*
  void cprimecount_SIGINT(int sig){
    printf("Got sigint\n");
  }

  void cprimecount_register_sigint() {
    signal(SIGINT, cprimecount_SIGINT);
  }
  */

  int64_t pi_int64(int64_t x) {
    return primecount::pi(x);
  }

  const char * pi_string(const char *xin) {
    std::string x = xin;
    std::string res = primecount::pi(x);
    return res.c_str();
  }

  int64_t pi_deleglise_rivat(int64_t x) {
    return primecount::pi_deleglise_rivat(x);
  }

  int64_t pi_legendre(int64_t x) {
    return primecount::pi_legendre(x);
  }

  int64_t pi_lehmer(int64_t x) {
    return primecount::pi_lehmer(x);
  }

  int64_t pi_meissel(int64_t x) {
    return primecount::pi_meissel(x);
  }

  int64_t pi_lmo(int64_t x) {
    return primecount::pi_lmo(x);
  }

  int64_t pi_primesieve(int64_t x) {
    return primecount::pi_primesieve(x);
  }

  int64_t nth_prime(int64_t n) {
    return primecount::nth_prime(n);
  }        

  int64_t prime_phi(int64_t x, int64_t a) {
    return primecount::phi(x,a);
  }

  int64_t prime_Li(int64_t x) {
    return primecount::Li(x);
  }

  int64_t prime_Li_inverse(int64_t x) {
    return primecount::Li_inverse(x);
  }    

  void prime_set_print_status(int print_status) {
    bool s = print_status ? true : false;
    primecount::set_print_status(s);
  }

  void prime_set_num_threads(int num_threads) {
    primecount::set_num_threads(num_threads);   
  }

  int prime_get_num_threads() {
    return primecount::get_num_threads();   
  }  

  int prime_test() {
    bool res = primecount::test();
    return res ? 1 : 0;
  }
  
  const char * pi_xmax() {
    std::string m = primecount::max();
    return m.c_str();
  }


  uint64_t primesieve_popcount(const uint64_t* array, uint64_t size) {
    return primesieve::popcount(array,size);
  }
  
  // Not in libprimecount API
  /*
  primecount::int128_t pi_deleglise_rivat128(primecount::int128_t x) {
    return primecount::pi_deleglise_rivat((primecount::int128_t) x);
  }
  */
}

