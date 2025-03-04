@echo off
call zig build -Dtarget=wasm32-emscripten
move zig-out\web\* pages\
start cmd /C run_server.bat
