if not exist ".\bin" mkdir .\bin
if not exist ".\bin-int" mkdir .\bin-int
START rgbasm -o ./bin-int/main.o ./src/lapis.asm
START rgblink -o ./bin/game.gb ./bin-int/main.o
START rgbfix -v -p 0 ./bin/game.gb
START ./bgb/bgb64.exe ./bin/game.gb