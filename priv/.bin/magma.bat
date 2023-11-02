@echo off
REM magma.bat - A script to invoke Mix tasks from the Obsidian vault, in particular the obsidian-shellcommands plugin

REM Check if `mix` is available in the path
where mix >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Mix command could not be found. Please ensure Elixir is installed.
    exit /b 1
)

REM Navigate to the main project directory
cd %~dp0\..\..

REM Execute the Mix task
mix %*
