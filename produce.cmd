set SOURCE=src/Main.elm 
set TEMP_FILE=main.js
set OUTPUT=dist/elm.js

echo "- Build..."
elm make %SOURCE% --optimize --output=%TEMP_FILE%
echo "- Optimize..."
uglifyjs %TEMP_FILE% --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle -o %OUTPUT%
echo "- Clean..."
del %TEMP_FILE%