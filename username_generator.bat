@echo off
color f
cd %~dp0"
::==============================================
::Optional variables..
::
set LogUsernameRawToFile=true
set AmountOfNamesToWrite=10
set Showhash=false
set AutoUpdate=true
::
::Will log the raw username with the md5 hash to the database/log file
::How many names to write to the screen
::Display the hash underneath the username
::Auto update the wordlist and MD5 script every 10th run
::==============================================
::Update variables
::
set UpdateLoop=5
set UpdateMd5=false
set UpdateWordlist=true
set UpdateMain=true
::
::How many runs we will go through before updating
::Update the md5 file?
::Update the wordlist? (recommended)
::Update the main file? (recommended)
::==============================================
set filename=%~n0%~x0
if not %filename%==username_generator.bat ren %filename% username_generator.bat & color cf & mode 80,10 & echo %filename% is the incorrect name for this script and it has been updated, please reload the script to apply changes & echo. & pause & exit

if not exist Usernames.txt echo Creating logfile... & call :databasecreate
cls
if not exist wordlist.txt echo Downloading wordlist... & call :downloadbyhackoo https://raw.githubusercontent.com/TTT2866/Batch-username-generator/master/wordlist.txt wordlist.txt
cls
if not exist md5.bat echo Downloading md5.bat... & call :downloadbyhackoo https://raw.githubusercontent.com/TTT2866/Batch-username-generator/master/md5.bat md5.bat
cls
if exist temp.txt del temp.txt
cls
if exist Download_update.bat del Download_update.bat
set num=0

set /p us=<wordlist.txt
set updatesignal=%us%
::this wont work unless you pass the variable for some reason
if %updatesignal%==Update_Ready call :updatemain


:start
set /a num=%num%+1

call :func
set word1=%random_word%
call :cap
set word1=%word1x%
call :func
set word2=%random_word%

set /a "randomnum=%random% %% 1000"
set username=%word1%%word2%%randomnum%

echo %username% >temp.txt

call :md5func

set database=Usernames.txt
for /F "delims=" %%a in ('findstr /I /N "%md5%" %database%') do set "datalookup=%%a"
if "%datalookup%"=="" (goto next) else goto start
:next
echo %username%
if %showhash%==true echo %md5%
if %LogUsernameRawToFile%==true (echo %md5% ^| %username% >>Usernames.txt) else (echo %md5% ^| >>Usernames.txt)

if %num%==%AmountOfNamesToWrite% (goto end) else (goto start)

:end
echo.
echo Done.
echo Press any key to exit
pause >nul


if not exist %temp%\update.txt echo 1 >%temp%\update.txt
set /p linenumber=<%temp%\update.txt
set /a newnum=%linenumber%+1
echo %newnum% >%temp%\update.txt
if %linenumber%==%UpdateLoop% call :update
exit

:func
set "file=wordlist.txt"
for /f %%# in (
    'findstr  /r /n "^" "%file%" ^|find /c ":"'
) do (
    set lines=%%#
)
set /a random_line=random_line=%random% %% %lines%
if random_line==0 (
    set "skip="
) else (
    set "skip=skip=%random_line%"
)

for /f "usebackq %skip%" %%# in ("%file%") do (
    set "random_word=%%#"
    goto :break
)   
:break
endlocal
goto :EOF

:md5func

set "file1=temp.txt"
call md5.bat "%file1%" md5
del temp.txt
goto :EOF

:cap
set x=%word1:~-0,1%
if %x%==a set firstcap=A
if %x%==b set firstcap=B
if %x%==c set firstcap=C
if %x%==d set firstcap=D
if %x%==e set firstcap=E
if %x%==f set firstcap=F
if %x%==g set firstcap=G
if %x%==h set firstcap=H
if %x%==i set firstcap=I
if %x%==j set firstcap=J
if %x%==k set firstcap=K
if %x%==l set firstcap=L
if %x%==m set firstcap=M
if %x%==n set firstcap=N
if %x%==o set firstcap=O
if %x%==p set firstcap=P
if %x%==q set firstcap=Q
if %x%==r set firstcap=R
if %x%==s set firstcap=S
if %x%==t set firstcap=T
if %x%==u set firstcap=U
if %x%==v set firstcap=V
if %x%==w set firstcap=W
if %x%==x set firstcap=X
if %x%==y set firstcap=Y
if %x%==z set firstcap=Z
set word1temp=%word1:~1%
set word1x=%firstcap%%word1temp%
goto :EOF

:databasecreate
echo ================================================================ >Usernames.txt
echo ^|      MD5 hash of username      ^|           Username          ^| >>Usernames.txt
echo ================================================================ >>Usernames.txt

goto :EOF

:downloadbyhackoo
Ping google.com -n 1 -w 1000
cls
if %errorlevel%==1 (set internet=nconnected) else (set internet=connected)
if %internet%==%nconnected% (echo Error.. you must be connected to internet to download the files required for this script to run. & pause >nul & exit)

::https://stackoverflow.com/questions/48860214/
Set "url=%~1%"
for %%# in (%url%) do ( set "File=%tmp%\%%~n#.txt" )
Call :Download "%url%" "%File%"
If exist "%File%" ( 
    ( Type "%File%")>con
Rem to save the contents in new text file
( Type "%File%" > %~2%)
)

::*********************************************************************************
:Download <url> <File>
Powershell.exe -command "(New-Object System.Net.WebClient).DownloadFile('%1','%2')"
::*********************************************************************************
goto :EOF

:update
pause
if %AutoUpdate%==true (
echo ================================================================  >>Usernames.txt
del %temp%\update.txt
if %UpdateWordList%==true del wordlist.txt & echo Updated wordlist.txt >>Usernames.txt
if %UpdateMD5%==true del md5.bat & echo Updated md5.bat >>Usernames.txt
echo ================================================================ >>Usernames.txt
)
goto :EOF

:updatemain
if %Autoupdate%==false goto start
::check for update signal in the wordlist  /
::if signal exists then make new file with the download script link /
::new file has download link, delete this file, and echo the wordlist WITHOUT update signal

::set /p updatesignal=<worlist.txt
::if not %updatesignal%==Update_Pending 


if exist %temp%\update_downloaded.log goto start
echo. >%temp%\update_downloaded.log
::for now this will only download the updated script once unless you clear the temp file


(
echo @echo off
echo cd %%~dp0"
echo del username_generator.bat
echo type wordlist.txt ^| findstr /v Update_Ready ^>wordlist2.txt 
echo del wordlist.txt
echo rename wordlist2.txt wordlist.txt
echo ================================================================ >>Usernames.txt
echo Updated username_generator.bat >>Usernames.txt
echo ================================================================ >>Usernames.txt
echo call :downloadbyhackoo https://raw.githubusercontent.com/TTT2866/Batch-username-generator/master/username_generator.bat username_generator.bat
echo exit
echo :downloadbyhackoo
echo Ping google.com -n 1 -w 1000
echo cls
echo if %%errorlevel%%==1 ^(set internet=nconnected^) else ^(set internet=connected^)
echo if %%internet%%==%%nconnected%% ^(echo Error.. you must be connected to internet to download the files required for this script to run. ^& pause ^>nul ^& exit^)

echo Set "url=%%~1%%"
echo for %%%%# in ^(%%url%%^) do ^( set "File=%%tmp%%\%%%%~n#.txt" ^)
echo Call :Download "%%url%%" "%%File%%"
echo If exist "%%File%%" ^( 
echo     ^( Type "%%File%%"^)^>con
echo ^( Type "%%File%%" ^> %%~2%%^)
echo ^)

echo ::*********************************************************************************
echo :Download ^<url^> ^<File^>
echo Powershell.exe -command "(New-Object System.Net.WebClient).DownloadFile('%%1','%%2')"
echo ::*********************************************************************************
echo goto :EOF

)>Download_update.bat

start "" Download_update.bat
exit
