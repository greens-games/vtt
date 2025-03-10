@echo off
odin build . -out:main -target:js_wasm32
move main.wasm .
start cmd /C python3 -m http.server 
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" http://localhost:8000
