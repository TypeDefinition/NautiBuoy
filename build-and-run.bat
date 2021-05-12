if not exist "./bin" mkdir ./bin
if not exist "./bin-int" mkdir ./bin-int
START rgbasm -o ./bin-int/lapis-obj.o ./src/lapis.asm
START rgblink -o ./bin/lapis.gb ./bin-int/lapis-obj.o
START rgbfix -f lhg -p 255 ./bin/lapis.gb
START ./bgb/bgb64.exe ./bin/lapis.gb