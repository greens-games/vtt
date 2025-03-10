@echo off
odin build client -out:main -target:js_wasm32
move main.wasm .
