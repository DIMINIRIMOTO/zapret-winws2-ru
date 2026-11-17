@echo off
chcp 65001 > nul

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Please run this file as Administrator.
    pause
    exit /b
)

cd /d "%~dp0"

:menu
cls
echo ==========================================
echo  1. Start Zapret (Manual Mode)
echo  2. Install as Windows Service
echo  3. Exit
echo ==========================================
echo.
set /p choice="Select an option (1-3): "

if "%choice%"=="1" goto run
if "%choice%"=="2" goto install
if "%choice%"=="3" goto exit

echo.
echo Invalid choice, please try again.
pause
goto menu

:install
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat zapret_game_init
echo:
set "BIN_PATH=%~dp0bins\"
set "LUA=%~dp0lua\"
set "LISTS=%~dp0files\"
set ARGS=^
--debug=0 --wf-tcp-out=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp-out=443,19294-19344,50000-50100,%GameFilterUDP% ^
--lua-init=@\"%LUA%blobs.lua\" ^
--lua-init=@\"%LUA%zapret-lib.lua\" ^
--lua-init=@\"%LUA%zapret-antidpi.lua\" ^
--name=\"Domain Bypass Quic\" ^
--filter-udp=443 ^
--hostlist=\"%LISTS%list-general.txt\" ^
--hostlist-exclude=\"%LISTS%list-exclude.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--payload=quic_initial ^
--lua-desync=fake:blob=quic_google:repeats=11 ^
--new ^
--name=\"Discord Voice\" ^
--filter-udp=19294-19344,50000-50100 ^
--filter-l7=discord,stun ^
--payload=discord_ip_discovery,stun ^
--lua-desync=fake:blob=ACTIVE_DISCORD:repeats=6 ^
--new ^
--name=\"Discord Media\" ^
--filter-tcp=2053,2083,2087,2096,8443 ^
--hostlist-domains=discord.media ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^
--name=\"Youtube\" ^
--filter-tcp=443 ^
--hostlist=\"%LISTS%list-google.txt\" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:ip_id=zero:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:ip_id=zero:repeats=8 ^
--new ^
--name=\"Domain Bypass TLS\" ^
--filter-tcp=80,443 ^
--hostlist=\"%LISTS%list-general.txt\" ^
--hostlist-exclude=\"%LISTS%list-exclude.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^
--name=\"IP Bypass Quic\" ^
--filter-udp=443 ^
--ipset=\"%LISTS%ipset-general.txt\" ^
--hostlist-exclude=\"%LISTS%list-exclude.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--payload=quic_initial ^
--lua-desync=fake:blob=quic_google:repeats=11 ^
--new ^
--name=\"IP Bypass TLS\" ^
--filter-tcp=80,443,8443 ^
--ipset=\"%LISTS%ipset-general.txt\" ^
--hostlist-exclude=\"%LISTS%list-exclude.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^
--name=\"GameFilter Bypass TCP\" ^
--filter-tcp=%GameFilterTCP% ^
--ipset=\"%LISTS%ipset-general.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--out-range=-n3 ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=unknown ^
--lua-desync=fake:blob=tls_sferum:tls_mod=rnd,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8:payload=all ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8:payload=all ^
--new ^
--name=\"GameFilter Bypass UDP\" ^
--filter-udp=%GameFilterUDP% ^
--ipset=\"%LISTS%ipset-general.txt\" ^
--ipset-exclude=\"%LISTS%ipset-exclude.txt\" ^
--out-range=-n2 ^
--payload=all ^
--lua-desync=fake:blob=ACTIVE_GAME:repeats=10:payload=all
sc create "zapret" binPath= "\"%BIN_PATH%winws2.exe\" %ARGS%" DisplayName= "zapret DPI bypass : winws2" start= auto
sc description "zapret" "zapret DPI bypass software"
sc start "zapret"
pause
exit /b

:run
call zapret_manager.bat zapret_set_ts
call zapret_manager.bat zapret_game_init
echo:
set "BIN=%~dp0bins\"
set "LUA=%~dp0lua\"
set "LISTS=%~dp0files\"
cd /d %BIN%
start "zapret: http,https,quic" /min "%BIN%winws2.exe" --debug=0 --wf-tcp-out=80,443,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp-out=443,19294-19344,50000-50100,%GameFilterUDP% ^

--lua-init=@"%LUA%blobs.lua" ^
--lua-init=@"%LUA%zapret-lib.lua" ^
--lua-init=@"%LUA%zapret-antidpi.lua" ^

--name="Domain Bypass Quic" ^
--filter-udp=443 ^
--hostlist="%LISTS%list-general.txt" ^
--hostlist-exclude="%LISTS%list-exclude.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--payload=quic_initial ^
--lua-desync=fake:blob=quic_google:repeats=11 ^
--new ^

--name="Discord Voice" ^
--filter-udp=19294-19344,50000-50100 ^
--filter-l7=discord,stun ^
--payload=discord_ip_discovery,stun ^
--lua-desync=fake:blob=ACTIVE_DISCORD:repeats=6 ^
--new ^

--name="Discord Media" ^
--filter-tcp=2053,2083,2087,2096,8443 ^
--hostlist-domains=discord.media ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^

--name="Youtube" ^
--filter-tcp=443 ^
--hostlist="%LISTS%list-google.txt" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:ip_id=zero:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:ip_id=zero:repeats=8 ^
--new ^

--name="Domain Bypass TLS" ^
--filter-tcp=80,443 ^
--hostlist="%LISTS%list-general.txt" ^
--hostlist-exclude="%LISTS%list-exclude.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^

--name="IP Bypass Quic" ^
--filter-udp=443 ^
--ipset="%LISTS%ipset-general.txt" ^
--hostlist-exclude="%LISTS%list-exclude.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--payload=quic_initial ^
--lua-desync=fake:blob=quic_google:repeats=11 ^
--new ^

--name="IP Bypass TLS" ^
--filter-tcp=80,443,8443 ^
--ipset="%LISTS%ipset-general.txt" ^
--hostlist-exclude="%LISTS%list-exclude.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--new ^

--name="GameFilter Bypass TCP" ^
--filter-tcp=%GameFilterTCP% ^
--ipset="%LISTS%ipset-general.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--out-range=-n3 ^
--payload=tls_client_hello ^
--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,dupsid,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=http_req ^
--lua-desync=fake:blob=tls_sferum:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8 ^
--payload=unknown ^
--lua-desync=fake:blob=tls_sferum:tls_mod=rnd,sni=www.google.com:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8:payload=all ^
--lua-desync=fakedsplit:pos=1:tcp_seq=2:tcp_ack=-66000:tcp_ts_up:repeats=8:payload=all ^
--new ^

--name="GameFilter Bypass UDP" ^
--filter-udp=%GameFilterUDP% ^
--ipset="%LISTS%ipset-general.txt" ^
--ipset-exclude="%LISTS%ipset-exclude.txt" ^
--out-range=-n2 ^
--payload=all ^
--lua-desync=fake:blob=ACTIVE_GAME:repeats=10:payload=all

exit /b