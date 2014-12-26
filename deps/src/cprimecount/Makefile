CPLIB = libcprimecount.so
all: $(CPLIB)

cprimecount.o: cprimecount.cpp
	$(CC) -Wall -c -O2 -fPIC cprimecount.cpp  -I../../usr/include

libcprimecount.so:  cprimecount.o
	gcc -Wall -shared -Wl,-soname,libcprimecount.so cprimecount.o -o $(CPLIB) \
           -lc -lstdc++ -L../../usr/lib/ -lprimecount -Wl,-rpath,'$(CURDIR)/../../usr/lib'

#           -lc -lstdc++ -L../../usr/lib/ -lprimecount -Wl,-rpath,/home/jlapeyre/.julia/v0.3/PrimeSieve/deps/usr/lib
#           -lc -lstdc++ -L../../usr/lib/ /home/jlapeyre/.julia/v0.3/PrimeSieve/deps/usr/lib/libprimecount.so.1.1.3

install: $(CPLIB)
	mkdir -p ../../usr/lib
	cp $(CPLIB) ../../usr/lib

clean:
	-rm *.o *.so
