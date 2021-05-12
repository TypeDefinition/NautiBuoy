mkdir -p ./bin
mkdir -p ./bin-int
rgbasm -o ./bin-int/lapis-obj.o ./src/lapis.asm
rgblink -o ./bin/lapis.gb ./bin-int/lapis-obj.o
rgbfix -f lhg -p 255 ./bin/lapis.gb
wine64 ./bgb/bgb64.exe ./bin/lapis.gb