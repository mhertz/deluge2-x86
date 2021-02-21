cd "%~dp0"
cd..
set PATH=%cd%\msys64\usr\bin;%PATH%
for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do set var2=%%i
mkdir python & curl -L https://www.python.org/ftp/python/%var2%/python-%var2%-embed-win32.zip | bsdtar xf - -C python
sed -i 's/#import/import/' python/python*._pth
curl https://bootstrap.pypa.io/get-pip.py | python\python.exe
for /f %%i in ('dir /b deluge-build\pycairo-*-win32.whl') do python\Scripts\pip install deluge-build\%%i
for /f %%i in ('dir /b deluge-build\PyGObject-*-win32.whl') do python\Scripts\pip install deluge-build\%%i
python\Scripts\pip install pygeoip
python\Scripts\pip install requests
python\Scripts\pip install windows-curses
python\Scripts\pip install pygame
python\Scripts\pip install gohlkegrabber
python\python -c "import ssl; ssl._create_default_https_context = ssl._create_unverified_context; from gohlkegrabber import GohlkeGrabber; gg = GohlkeGrabber(); gg.retrieve('.', 'twisted', platform='win32')"
python\python -c "import ssl; ssl._create_default_https_context = ssl._create_unverified_context; from gohlkegrabber import GohlkeGrabber; gg = GohlkeGrabber(); gg.retrieve('.', 'setproctitle', platform='win32')"
for /f %%i in ('dir /b twisted-*-win32.whl') do python\Scripts\pip install %%i
for /f %%i in ('dir /b setproctitle-*-win32.whl') do python\Scripts\pip install %%i
python\Scripts\pip uninstall -y gohlkegrabber lxml
del twisted-*-win32.whl
del setproctitle-*-win32.whl
mkdir python\future
for /f %%i in ('curl https://api.github.com/repos/PythonCharmers/python-future/releases/latest ^| grep tarball_url ^| cut -d'^"' -f4') do curl -L %%i | bsdtar xf - -C python\future --strip-components 1
for /f %%i in ('dir /b python\python*._pth') do echo future >> python\%%i
python\Scripts\pip install python\future
sed -i '/future/d' python/python*._pth
rd /s /q python\future
rd /s /q python\future 2>nul
copy /y loaders\cli\* python\Lib\site-packages\pip\_vendor\distlib
python\Scripts\pip install git+https://github.com/deluge-torrent/deluge
copy python\Scripts\deluge-console.exe python
copy /y loaders\* python\Lib\site-packages\pip\_vendor\distlib
python\Scripts\pip install --ignore-installed --no-deps git+https://github.com/deluge-torrent/deluge
for /f %%i in ('dir /b python\Lib\site-packages\deluge-*') do set var=%%i
patch python/Lib/site-packages/twisted/internet/_glibbase.py < deluge-build\_glibbase.patch
patch python/Lib/site-packages/deluge/ui/client.py < deluge-build\client.patch
patch python/Lib/site-packages/deluge/ui/gtk3/common.py < deluge-build\common.patch
patch python/Lib/site-packages/deluge/core/preferencesmanager.py < deluge-build\preferencesmanager.patch
curl https://github.com/deluge-torrent/deluge/commit/543a91bd9b06ceb3eee35ff4e7e8f0225ee55dc5.patch | patch -d python/Lib/site-packages -p1 --no-backup-if-mismatch
patch python/Lib/site-packages/deluge/log.py < deluge-build\logging.patch
patch python/Lib/site-packages/deluge/ui/console/modes/basemode.py < deluge-build\consoleCommandLineOnWin.patch
patch -R python/Lib/site-packages/cairo/__init__.py < deluge-build\pycairo_py3_8_load_dll.patch
patch -R python/Lib/site-packages/gi/__init__.py < deluge-build\pygobject_py3_8_load_dll.patch
patch -d python/Lib/site-packages -p1 --no-backup-if-mismatch < deluge-build\48040b1fe76e17e0776418bfd8bc88bd27013a84.patch
bsdtar xf python/Lib/site-packages/deluge/plugins/Notifications*.egg
patch -p1 -d deluge_notifications < deluge-build\notifications.patch
bsdtar cf python/Lib/site-packages/deluge/plugins/Notifications* --format zip EGG-INFO deluge_notifications
rd /s /q EGG-INFO deluge_notifications
curl https://github.com/deluge-torrent/deluge/commit/b27ad9126655ca758e232e89dce70d6bdf69bd3b.patch | patch -d python/Lib/site-packages -p1
curl https://github.com/deluge-torrent/deluge/commit/0e48c9712d579acfe3064b011d61ffef84c2bef5.patch | patch -d python/Lib/site-packages -p1
patch -p1 -d python/Lib/site-packages/deluge/core -p1 < deluge-build\listen.patch
curl https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/deluge/trunk/user-agent-override.diff | patch -d python/Lib/site-packages -p1
patch -p1 --no-backup-if-mismatch -d python/Lib/site-packages -p1 < deluge-build\f7d5c624940b0b7d0c8081129e81202e1d35fcbd.patch
copy python\Scripts\deluge.exe python
copy python\Scripts\deluged.exe python
copy python\Scripts\deluged-debug.exe python
copy python\Scripts\deluge-debug.exe python
copy python\Scripts\deluge-gtk.exe python
copy python\Scripts\deluge-web.exe python
copy python\Scripts\deluge-web-debug.exe python
rd /s /q python\Scripts
rd /s /q python\Scripts 2>nul
python\python.exe deluge-build\portable.py -f python\deluged.exe -s %cd%\python\python.exe -r pythonw.exe
python\python.exe deluge-build\portable.py -f python\deluged-debug.exe -s %cd%\python\python.exe -r python.exe
python\python.exe deluge-build\portable.py -f python\deluge-web.exe -s %cd%\python\python.exe -r pythonw.exe
python\python.exe deluge-build\portable.py -f python\deluge-web-debug.exe -s %cd%\python\python.exe -r python.exe
python\python.exe deluge-build\portable.py -f python\deluge.exe -s %cd%\python\pythonw.exe -r pythonw.exe
python\python.exe deluge-build\portable.py -f python\deluge-debug.exe -s %cd%\python\python.exe -r python.exe
python\python.exe deluge-build\portable.py -f python\deluge-gtk.exe -s %cd%\python\pythonw.exe -r pythonw.exe
python\python.exe deluge-build\portable.py -f python\deluge-console.exe -s %cd%\python\python.exe -r python.exe
python\python.exe deluge-build\fixdeluged.py
python\python.exe deluge-build\fixdeluge-web.py
xcopy /ehq overlay python
del python\Lib\site-packages\easy_install.py
del python\Lib\site-packages\PyWin32.chm
rd /s /q python\Lib\site-packages\PIL
rd /s /q python\Lib\idlelib
rd /s /q python\Lib\distutils
rd /s /q python\Lib\site-packages\pip
rd /s /q python\Lib\site-packages\setuptools
rd /s /q python\Lib\site-packages\pythonwin
rd /s /q python\Doc
rd /s /q python\libs
rd /s /q python\include
rd /s /q python\Tools
rd /s /q python\tcl
for /f %%i in ('dir /b /a:d deluge-2* ^| findstr dev') do rd /s /q %%i
for /f %%i in ('dir /b /a:d deluge-2* ^| findstr dev') do rd /s /q %%i 2>nul
xcopy /ehq python %var:~0,-10%\
rd /s /q python
rd /s /q python 2>nul
