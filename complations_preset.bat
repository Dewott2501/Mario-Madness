@echo off
setlocal

haxelib install flixel-addons 3.1.1
haxelib install flixel 5.3.1
haxelib install flixel-ui 2.5.0
haxelib install flixel-tools 1.5.1
haxelib install hxCodec 2.6.1
haxelib install lime 8.0.2
haxelib install openfl 9.2.0

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
