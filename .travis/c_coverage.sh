luarocks make --local \
    CFLAGS="-O0 -fPIC -ftest-coverage -fprofile-arcs" \
    LIBFLAG="-shared --coverage" && busted
