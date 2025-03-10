@echo off
odin build . -out:main -target:js_wasm32
move main.wasm .
