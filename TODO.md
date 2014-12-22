### Extend libsieve

The current Julia package covers all or nearly all of the libsieve API.
One could extend this by writing more C/C++ code, to

* return arrays of prime-tuples rather than just print them
* search for prime gaps, etc.
* print to a stream rather than STDOUT
  (Or, write a Julia wrapper to redirect STDOUT.)
* allow Julia callbacks when primes are found.

### Tables

* allow verifying the tables with Oliveira e Silva's text tables, for
  corruption, or if he publishes corrections, etc. This would not
  be difficult.

* allow loading other tables. There are a few out there, and the effort
  would not be great. But, from the tables I saw, there is little
  to be gained.

* allow building other tables. This problem is probably too unique for
  a user-friendly API like approach. Most of the current tables have
  ```10^4``` entries. It seems reasonable only to add tables of
  ```10^5``` entries. The current tables are in a file of about
  4MB. The size would, of course, increase by an order of magnitude.
