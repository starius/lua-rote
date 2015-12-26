export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin
export PATH=${PATH}:${TRAVIS_BUILD_DIR}/install/luarocks/bin
export PATH=${PATH}:~/.luarocks/bin
bash .travis/setup_lua.sh
eval `$HOME/.lua/luarocks path`
