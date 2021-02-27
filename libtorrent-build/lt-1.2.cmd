cd "%~dp0"
cd..
set BOOST_ROOT=%cd%\boost
set PYTHON_ROOT=%cd%\python
set PYTHON_ROOT2="%PYTHON_ROOT:\=/%"
set OPENSSL=%cd%\OpenSSL-Win32
set BOOST_BUILD_PATH=%BOOST_ROOT%\tools\build
set PATH=%PATH%;%BOOST_BUILD_PATH%\src\engine\bin.ntx86;%BOOST_ROOT%;%cd%\python;%cd%\msys64\usr\bin
mkdir boost & curl -L https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.zip | bsdtar xf - --strip-components 1 -C boost
git clone https://github.com/arvidn/libtorrent -b RC_1_2 lt
for /f %%i in ('git ls-remote --tags https://github.com/python/cpython ^| grep -E 'v3.8.[0-9]$' ^| cut -d/ -f3 ^| tr -d "^{}" ^| tr -d v') do set var2=%%i
for /f %%i in ('echo %var2% ^| cut -d. -f1-2 ^| tr -d .') do set PYTHONVER=%%i
for /f %%i in ('echo %var2% ^| cut -d. -f1-2') do set PYTHONVER2=%%i
mkdir python & curl -L https://www.nuget.org/api/v2/package/pythonx86/%var2% | bsdtar xf - -C python --include tools --strip-components 1
msys64\usr\bin\echo -e "Lib\nDLLs\nimport site" >> python\python%PYTHONVER%._pth
call msvc\VC\Auxiliary\Build\vcvars32.bat
pushd boost
call bootstrap.bat
popd
pushd lt\bindings\python
echo using python : %PYTHONVER2% : %PYTHON_ROOT2% : %PYTHON_ROOT2%/include : %PYTHON_ROOT2%/libs ; > %BOOST_BUILD_PATH%\user-config.jam
b2 crypto=openssl libtorrent-link=static boost-link=static release optimization=speed stage_module --abbreviate-paths -j4 address-model=32 openssl-include=%OPENSSL%\include openssl-lib=%OPENSSL%\lib lto=on
popd
copy /y lt\bindings\python\libtorrent.pyd overlay\Lib\site-packages
for /f %%i in ('dir /b deluge-2* ^| findstr /v dev') do copy /y lt\bindings\python\libtorrent.pyd %%i\Lib\site-packages
for /f %%i in ('dir /b deluge-2* ^| findstr dev') do copy /y lt\bindings\python\libtorrent.pyd %%i\Lib\site-packages
rd /s /q boost
rd /s /q boost 2>nul
rd /s /q lt
rd /s /q lt 2>nul
rd /s /q python
rd /s /q python 2>nul
