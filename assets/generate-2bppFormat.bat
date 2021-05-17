rm -r 2bppFormat
mkdir 2bppFormat

cd Sprites
for %%i in (*.png); do rgbgfx -o ..\2bppFormat\%%i.2bpp %%i