REM @RD Remove Directory
REM /S Removes all directories and files in the specified directory in addition to the directory itself.  Used to remove a directory tree.
REM /Q Quiet mode, do not ask if ok to remove a directory tree with /S

@RD /S /Q ".\bin"
@RD /S /Q ".\bin-int"
@RD /s /Q ".\tile_data"