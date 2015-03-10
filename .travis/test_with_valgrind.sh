if [ "$LUA" != "luajit" ]; then
    # re-build in Debug mode
    luarocks make --local CFLAGS="-O0 -g -fPIC"
    # make busted which does not call os.exit
    BUSTED=/usr/local/lib/luarocks/rocks/busted/*/bin/busted
    sed '1 s/.*/os.exit = function() end/g' \
        < $BUSTED > exitless-busted
    # valgrind...
    valgrind --error-exitcode=1 --leak-check=full \
        lua exitless-busted
fi
