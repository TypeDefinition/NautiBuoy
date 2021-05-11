mkdir -p ./bin
mkdir -p ./bin-int
rgbasm -o ./bin-int/main.o ./src/test.asm
rgblink -o ./bin/prison-break.gb ./bin-int/main.o
rgbfix -v -p 0 ./bin/prison-break.gb
wine64 ./bgb/bgb64.exe ./bin/prison-break.gb