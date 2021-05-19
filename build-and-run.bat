if not exist ".\bin" mkdir .\bin
if not exist ".\bin-int" mkdir .\bin-int
if not exist ".\tile_data" mkdir .\tile_data

for /r ".\assets" %%i in (*.png); do rgbgfx -o .\tile_data\%%~ni.2bpp %%i
for /r ".\src" %%i in (*.asm); do rgbasm -o .\bin-int\%%~ni.o %%i

for /r ".\bin-int" %%i in (*.o); do call set "OBJFiles=%%OBJFiles%% %%~i"
rgblink -o .\bin\lapis.gb -n .\bin-int\symbols.sym %OBJFiles%

rgbfix -f lhg -p 255 .\bin\lapis.gb
java -jar .\Emulicious\Emulicious.jar .\bin\lapis.gb