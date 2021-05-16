mkdir -p ./bin
mkdir -p ./bin-int
rgbasm -o ./bin-int/lapis-obj.o ./src/lapis.asm
rgbasm -o ./bin-int/assets-obj.o ./src/assets.asm
rgbasm -E ./bin-int/assets-map.map ./src/assets.asm
rgblink -o ./bin/lapis.gb ./bin-int/assets-obj.o -n ./bin-int/assets-map.map ./bin-int/lapis-obj.o
rgbfix -f lhg -p 255 ./bin/lapis.gb
wine64 ./bgb/bgb64.exe ./bin/lapis.gb