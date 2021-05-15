if not exist ".\bin" mkdir .\bin
if not exist ".\bin-int" mkdir .\bin-int
START rgbasm -o ./bin-int/lapis-obj.o ./src/lapis.asm
START rgbasm -o ./bin-int/assets-obj.o ./src/assets.asm
START rgbasm -E ./bin-int/assets-map.map ./src/assets.asm
START rgblink -o ./bin/lapis.gb ./bin-int/assets-obj.o -n ./bin-int/assets-map.map ./bin-int/lapis-obj.o
START rgbfix -f lhg -p 255 ./bin/lapis.gb
START ./bgb/bgb64.exe ./bin/lapis.gb