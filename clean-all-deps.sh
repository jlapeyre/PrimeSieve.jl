#
rm -f deps/usr/lib/*
rm -rf deps/builds/*
echo cleaning cprimecount
cd deps/src/cprimecount/; make clean ; cd ../../..
echo cleaning msieve-shared
cd deps/src/msieve-shared-0.0.2; make clean;  cd ../../..
