@echo off
setlocal EnableDelayedExpansion

REM ---------------------------------------------------------------------------
REM Refresh the skill library on this machine.
REM
REM   1. git pull                  - fetch new skill content from GitHub
REM   2. validate                  - catch a broken skill before it gets used
REM   3. plugin marketplace update - re-read the marketplace definition
REM
REM Runs both pull and marketplace update deliberately. Whether a local-path
REM marketplace re-reads per session or caches is untested; doing both makes the
REM question moot. NEVER use "marketplace remove" to refresh - that uninstalls
REM every plugin from it.
REM
REM Everything is written to scripts\sync.log so a failure can be read after the
REM window closes. Pauses at the end when double-clicked, not when scheduled.
REM ---------------------------------------------------------------------------

cd /d "%~dp0.."
set "LOG=%~dp0sync.log"
set "FAILED="

> "%LOG%" echo ===== sync started %DATE% %TIME% =====
call :say "Repo: %CD%"

REM --- 1. pull ---------------------------------------------------------------
call :say ""
call :say "[1/3] Pulling latest skills..."
git pull --ff-only >> "%LOG%" 2>&1
if errorlevel 1 (
  call :say "  FAILED: git pull. Common causes:"
  call :say "    - unpushed local commits, or diverged history"
  call :say "    - stale .git\index.lock  (delete it and retry)"
  call :say "    - git asking for credentials it cannot prompt for"
  set "FAILED=1"
) else (
  call :say "  ok"
)

REM --- 2. validate -----------------------------------------------------------
REM Find a working Python. Windows installs vary: py launcher, python, python3.
call :say ""
call :say "[2/3] Validating..."
set "PY="
for %%C in (py python python3) do (
  if not defined PY (
    %%C --version >nul 2>&1 && set "PY=%%C"
  )
)
if not defined PY (
  call :say "  SKIPPED: no Python found on PATH (tried py, python, python3)."
  call :say "    Not fatal - validation is a safety net, not a requirement."
) else (
  call :say "  using: !PY!"
  !PY! scripts\validate.py >> "%LOG%" 2>&1
  if errorlevel 1 (
    call :say "  validation reported errors - see log below."
    call :say "    ONE failure is expected: improve-system, pending the Notion lesson log."
    call :say "    Anything else should be fixed before these skills are relied on."
  ) else (
    call :say "  PASS"
  )
)

REM --- 3. marketplace --------------------------------------------------------
call :say ""
call :say "[3/3] Refreshing marketplace..."
where claude >nul 2>&1
if errorlevel 1 (
  call :say "  FAILED: 'claude' not found on PATH."
  call :say "    The CLI is installed but not visible to this shell."
  set "FAILED=1"
) else (
  claude plugin marketplace update skill-stack >> "%LOG%" 2>&1
  if errorlevel 1 (
    call :say "  FAILED: marketplace update returned an error - see log."
    set "FAILED=1"
  ) else (
    call :say "  ok"
  )
)

REM --- summary ---------------------------------------------------------------
call :say ""
if defined FAILED (
  call :say "RESULT: finished WITH ERRORS. Full detail: %LOG%"
) else (
  call :say "RESULT: all good."
)
call :say "===== sync ended %DATE% %TIME% ====="

REM Pause only when double-clicked. Scheduled runs must not hang on a prompt.
echo %CMDCMDLINE% | find /i "%~nx0" >nul
if not errorlevel 1 (
  echo.
  echo Press any key to close...
  pause >nul
)
endlocal & exit /b 0

:say
REM An empty arg must print a real blank line. Plain "echo" with nothing after it
REM prints "ECHO is off." instead, which made clean runs look like failures.
if "%~1"=="" (
  echo.
  >> "%LOG%" echo.
) else (
  echo %~1
  >> "%LOG%" echo %~1
)
goto :eof
