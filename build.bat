@echo off

echo Assembling...
if NSF_FILE neq 1 goto normal
tools\asm6f.exe vulpreich.asm -n -c -L %* bin\vulpreich.nsf > bin\assembler.log
if %ERRORLEVEL% neq 0 goto buildfail
move /y vulpreich-nsf.lst bin > nul
move /y vulpreich-nsf.cdl bin > nul
echo Done.
echo.


goto end

:normal
tools\asm6f.exe vulpreich.asm -n -c -L %* bin\vulpreich.nes > bin\assembler.log
if %ERRORLEVEL% neq 0 goto buildfail
move /y vulpreich.lst bin > nul
move /y vulpreich.cdl bin > nul
echo Done.
echo.

echo SHA1 hash check:
echo 47ba60fad332fdea5ae44b7979fe1ee78de1d316ee027fea2ad5fe3c0d86f25a PRG0
echo Yours:
certutil -hashfile bin\vulpreich.nes SHA256 | findstr /V ":"


goto end

:buildfail
echo The build seems to have failed.
goto end

:buildsame
echo Your built ROM and the original are the same.
goto end

:builddifferent
echo Your built ROM and the original differ.
echo If this is intentional, you're all set.
goto end


:end
echo on
