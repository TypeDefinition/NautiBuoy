# Understanding the "-exec" option of "find": https://unix.stackexchange.com/questions/389705/understanding-the-exec-option-of-find/389706
# Seperate filename & path inside "find"'s' "-exec" option: https://unix.stackexchange.com/questions/178217/separate-filename-and-path-inside-find-commands-exec-option
mkdir -p ./bin
mkdir -p ./bin-int
mkdir -p ./tile_data

find ./assets/tiles -type f -name '*.png' -exec sh -c 'rgbgfx -o ./tile_data/$(basename "{}" .png).2bpp $0' {} \;
find ./assets/sprites -type f -name '*.png' -exec sh -c 'rgbgfx -h -o ./tile_data/$(basename "{}" .png).2bpp $0' {} \;
find ./src/ -type f -name '*.asm' -exec sh -c 'rgbasm -o ./bin-int/$(basename "{}" .asm).o $0' {} \;
find ./bin-int/ -type f -name '*.o' -exec rgblink -o ./bin/gbgame.gb -n ./bin/gbgame.sym -m ./bin/gbgame.map {} +
rgbfix -f lhg -p 255 ./bin/gbgame.gb