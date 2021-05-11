START rgbasm -o ./bin-int/main.o ./src/test.asm
START rgblink -o ./bin/prison-break.gb ./bin-int/main.o
START rgbfix -v -p 0 ./bin/prison-break.gb
START ./bgb/bgb64.exe ./bin/prison-break.gb