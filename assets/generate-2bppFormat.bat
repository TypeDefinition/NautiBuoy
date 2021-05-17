rm -r ..\src\2bppFormat
mkdir ..\src\2bppFormat

cd Sprites
for %%i in (*.png); do rgbgfx -o ..\..\src\2bppFormat\%%i.2bpp %%i