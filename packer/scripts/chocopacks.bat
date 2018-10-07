:: Ensure C:\Chocolatey\bin is on the path
set /p PATH=<C:\Windows\Temp\PATH

:: Install all the things; for example:
cmd /c choco install -y 7zip
cmd /c choco intall -y psexec
cmd /c choco install -y visualstudiocode