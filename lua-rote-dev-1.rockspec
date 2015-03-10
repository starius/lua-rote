package = "lua-rote"
version = "dev-1"
source = {
    url = "git://github.com/starius/lua-rote.git"
}
description = {
    summary = "libROTE Lua bindings",
    homepage = "https://github.com/starius/lua-rote",
    license = "LGPL 2.1",
}
dependencies = {
    "lua >= 5.1"
}
 external_dependencies = {
    ROTE = {
        header = "rote/rote.h"
    }
}
build = {
    type = "builtin",
    modules = {
        ['rote'] = {
            sources = {
                "src/rote.c",
                "src/attr.c",
                "src/color.c",
                "src/lua-rote.c",
            },
            incdirs = {"$(ROTE_INCDIR)"},
            libdirs = {"$(ROTE_LIBDIR)"},
            libraries = {"rote"},
        },
    },
}
