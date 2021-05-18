if not exist ".\bin" mkdir .\bin
if not exist ".\bin-int" mkdir .\bin-int
if not exist ".\tile_data" mkdir .\tile_data

for %%f in (.\assets\*.png); do START rgbgfx -o ./tile_data/~%%n.2bpp %%f
cmd /k