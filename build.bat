@echo off
call zig build -Dtarget=wasm32-emscripten
move zig-out\web\* .\
move /Y main.html index.html
start cmd /C run_server.bat
