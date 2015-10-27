if [ "$LUA" != "luajit" ]; then
    # re-build in Debug mode
    luarocks make --local CFLAGS="-O0 -g -fPIC"
    # make busted which does not call os.exit
    echo 'os.exit = function() end' > exitless-busted
    echo 'require "busted.runner"({ standalone = false, batch = true })' \
        >> exitless-busted
    # valgrind...
    valgrind --error-exitcode=1 --leak-check=full \
        --gen-suppressions=all \
        --suppressions=.travis/nsswitch_c_678.supp \
        lua exitless-busted
fi
