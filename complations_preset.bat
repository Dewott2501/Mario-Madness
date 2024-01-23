@echo off
setlocal

haxelib set flixel-addons 3.1.1
haxelib set flixel 5.3.1
haxelib set flixel-ui 2.5.0
haxelib set flixel-tools 1.5.1
haxelib set hxCodec 2.6.1
echo Config ready
echo Do you want to compile? (Y/N)
set /p respuesta=

if /i "%respuesta%"=="Y" (
    echo Compiling... This can take a while
    lime test windows -debug
    pause
) else if /i "%respuesta%"=="N" (
    echo Exiting...
) else (
    echo Invalid Answer
)